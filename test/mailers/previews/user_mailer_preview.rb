# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  # このEメールをhttp://localhost:3000/rails/mailers/user_mailer/account_activationでプレビューしてください。
  def account_activation
    user = User.first # DBの最初のユーザーをとる

    # 有効化トークン（メールテンプレート内で使用しているため省略不可）
    user.activation_token = User.new_token # ランダムなトークンを返す

    UserMailer.account_activation(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset
  end

end
