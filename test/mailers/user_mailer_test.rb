require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  # アカウントの開設
  test "account_activation" do
    user = users(:michael) # fixtureからmichaelを取得する
    user.activation_token = User.new_token # 有効化トークンを生成する
    # Userメイラーのアカウント有効化処理にテストユーザー情報を渡して、メールオブジェクトを作成する
    mail = UserMailer.account_activation(user)
    # メールオブジェクトの件名をチェックする
    assert_equal "Account activation", mail.subject
    # メールオブジェクトの送信先メールアドレスをチェックする
    assert_equal [user.email], mail.to
    # メールオブジェクトの送信元メールアドレスをチェックする
    assert_equal ["noreply@example.com"], mail.from
    # テストユーザーの名前が、メールの本文に含まれているかチェックする
    assert_match "Hi", mail.body.encoded
    assert_match user.name, mail.body.encoded
    # テストユーザーの有効化トークンが、メールの本文に含まれているかチェックする
    assert_match user.activation_token, mail.body.encoded
    # テストユーザーのアドレスがエスケープされて、メールの本文に含まれているかチェックする
    assert_match CGI.escape(user.email), mail.body.encoded
    # assert_match user.email, mail.body.encoded # これだと落ちる
  end


  # test "password_reset" do
  #   mail = UserMailer.password_reset
  #   assert_equal "Password reset", mail.subject
  #   assert_equal ["to@example.org"], mail.to
  #   assert_equal ["from@example.com"], mail.from
  #   assert_match "Hi", mail.body.encoded
  # end

end
