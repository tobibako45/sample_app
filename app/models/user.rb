class User < ApplicationRecord

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
  validates :password, presence: true, length: {minimum: 6}

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
