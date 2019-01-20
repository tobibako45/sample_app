class User < ApplicationRecord
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
