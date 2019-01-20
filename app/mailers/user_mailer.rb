class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject



  # アカウント有効化リンクをメール送信する
  # 自動生成された、account_activationメソッドを編集する。
  # ユーザー情報のインスタンス変数を作成し、user.email宛にメールを送信する。
  def account_activation(user)
    # @greeting = "Hi"
    @user = user
    # mail to: "to@example.org"
    mail to: user.email, subject: "Account activation"
  end



  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
