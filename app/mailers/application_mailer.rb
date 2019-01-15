class ApplicationMailer < ActionMailer::Base
  # デフォルトのfromアドレスを編集する。
  # なお、この値はアプリケーション全体で共通となる。
  default from: 'noreply@example.com'
  layout 'mailer'
end
