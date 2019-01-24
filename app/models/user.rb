class User < ApplicationRecord
  # micropostは、その所有者 (ユーザー) と一緒に破棄されることを保証する
  has_many :microposts, dependent: :destroy

  # 能動的関係に対して1対多(has_many)の関連付け
  # active_relationships => Railsに探して欲しいモデルのクラス名を明示的に伝える
  #
  # ユーザーを削除したら、ユーザーのリレーションシップも同時に削除される必要があります。
  # そのため、関連付けにdependent: :destroyも追加しています。
  has_many :active_relationships, class_name: "Relationship",
           foreign_key: "follower_id",
           dependent: :destroy


  # 受動関係を使ってuser.followersを実装する
  has_many :passive_relationships, class_name: "Relationship",
           foreign_key: "followed_id",
           dependent: :destroy


  # Userモデルにfollowingの関連付けを追加
  # 「following配列の元は、followed idの集合である」ということを明示的にRailsに伝える
  has_many :following, through: :active_relationships, source: :followed

  # 「followers配列の元は、follower idの集合である」ということを明示的にRailsに伝える
  # これは:followers属性の場合、Railsが「followers」を単数形にして自動的に外部キーfollower_idを探してくれるからです。
  # リスト 14.12と違って必要のない:sourceキーをそのまま残しているのは、has_many :followingとの類似性を強調させるためです。
  has_many :followers, through: :passive_relationships, source: :follower

  # has_many :followers, through: :passive_relationships # これでもいい


  attr_accessor :remember_token, :activation_token, :reset_token

  # before_save オブジェクトがDBに保存される直前で実行。INSERT、UPDATE両方で実行
  before_save :downcase_email
  # before_create オブジェクトがDBに新規保存(INSERT)される直前で実行
  before_create :create_activation_digest


  # バリデーション

  # email属性を小文字に変換してメールアドレスの一意性を保証する
  # before_save オブジェクトが保存される時点で処理を実行
  before_save {self.email = email.downcase}
  # before_save { self.email = email.downcase! } # メソッドの末尾に!を付け足すことにより、email属性を直接変更できるようになります

  # nameは必須。 文字数制限
  validates :name, presence: true, length: {maximum: 50}

  # メールアドレスの正規表現を定数に代入
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # ２つの連続したドットはマッチさせないようにする
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  # emailは必須。 文字数制限
  # メールアドレスの一意性を検証する
  # uniqueness: true
  # メールアドレスの大文字小文字を無視した一意性の検証
  # uniqueness: { case_sensitive: false }

  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}

  has_secure_password
  # validates :password, presence: true, length: {minimum: 6}
  # 空だった時に例外処理をするオプション　allow_nil: true
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  #   def authenticated?(remember_token)
  #     return false if remember_digest.nil?
  #     BCrypt::Password.new(remember_digest).is_password?(remember_token)
  #   end


  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end


  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)

    # update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)

    update_columns("reset_digest" => User.digest(reset_token), "reset_sent_at" => Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end


  # 試作feedの定義 から、ちゃんとしたやつ
  def feed
    # Micropost.where("user_id = ?", id)
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # Micropost.where("user_id IN (?) ", following_ids)
    # Micropost.all
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", following_ids: following_ids, user_id: id)

    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end


  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end


  private


  # メールアドレスをすべて少文字にする
  def downcase_email
    # self.email = email.downcase
    email.downcase!
  end

  # 有効化トークンと有効化ダイジェストを作成、代入する
  def create_activation_digest
    # ランダムなトークンを作成、代入
    self.activation_token = User.new_token
    # 渡された文字列のハッシュ値を作成。あと代入
    self.activation_digest = User.digest(activation_token)
  end

end
