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


  # パスワード再設定用メイラーメソッドのテスト
  test "password_reset" do
    # michaelユーザの情報を取得
    user = users(:michael)
    # パスワード再設定トークンをセット
    user.reset_token = User.new_token
    # パスワード再設定メールを送信
    mail = UserMailer.password_reset(user)
    # メールオブジェクトの件名に、"Password reset"が含まれているかチェック
    assert_equal "Password reset", mail.subject
    # メールオブジェクトの宛先が、ユーザのemailと一致しているかチェック
    assert_equal [user.email], mail.to
    # メールオブジェクトのfromアドレスが、noreply@example.comと一致しているかチェック
    assert_equal ["noreply@example.com"], mail.from
    # テストユーザのパスワード再設定トークンが、エンコードされたメール本文内に存在するかチェック
    assert_match user.reset_token,        mail.body.encoded
    # テストユーザのアドレスがエスケープされて、エンコードされたメール本文に含まれているかチェックする
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
