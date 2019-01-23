require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # setupメソッド内に書かれた処理は、各テストが走る直前に実行されます。
  # def setup
  #   # @user = User.new(name: "SHOGO", email: "tobibako@gmail.com" )
  #   @user = User.new(name: "Example User", email: "user@example.com")
  # end

  # パスワードとパスワード確認を追加する
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end



  # 有効であるべき
  test "should be valid" do
    assert @user.valid?
  end

  # nameがあるはず
  test "name should be present" do
    @user.name = ""

    # assert @user.valid?

    # assert_not で assert　の逆をチェック。この場合は、「nameが無いはず」
    assert_not @user.valid?
  end

  # emailがあるはず
  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end


  # 名前文字数制限
  # 51文字の文字列を簡単に作るために文字列のかけ算を使いました。
  # test "名前文字数制限" do
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  #
  # test "メール文字数制限" do
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end


  # test "有効なメールアドレスを調べる" do
  test "email validation should accept valid addresses" do

    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]

    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address} should be valid" # 有効であるべき
    end

  end


  # test "電子メールの検証は無効なアドレスを拒否する必要があります" do
  test "email validation should reject invalid addresses" do

    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]

      invalid_addresses.each do |invalid_address|
        @user.email = invalid_address
        assert_not @user.valid?, "#{invalid_address} should be invalid" # 無効であるべき
      end

  end


  # test "メールアドレスは一意である必要があります" do
  test "email addresses should be unique" do
    # dupは、同じ属性を持つデータを複製するためのメソッドです。
    # @userを保存した後では、複製されたユーザーのメールアドレスが既にデータベース内に存在するため、ユーザの作成は無効になるはずです。
    duplicate_user = @user.dup

    # 大文字小文字を区別しない、一意性のテスト
    duplicate_user.email = @user.email.upcase
    @user.save

    # duplicate_userがなかったらtrue
    # 大文字小文字を区別しているため
    assert_not duplicate_user.valid?
  end


  # メールアドレスを小文字にするテスト
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # パスワードが存在するはずです（空白ではありません）
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  # パスワードは最小長でなければなりません
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # ダイジェストが存在しない場合のauthenticated?のテスト
  test "authenticated? should return false for a user with nil digest" do
    # assert_not @user.authenticated?('')
    assert_not @user.authenticated?(:remember, '')
  end


  # dependent: :destroyのテスト。関連するmicropostsは破壊されるべきです
  test "associated microposts should be destroyed" do
    # ユーザーをDBに保存
    @user.save
    # ユーザーに紐付いたマイクロポストを生成する
    @user.microposts.create!(content: "Lorem ipsum")
    # マイクロソフトの数が-1されていることを確認
    assert_difference 'Micropost.count', -1 do
      # ユーザーを削除する
      @user.destroy
    end
  end



  # “following” 関連のメソッドをテスト
  # ユーザーをフォローしてフォローを解除する
  test "should follow and unfollow a user" do

    # fixtureからmichaelの情報を取得
    michael = users(:michael)
    # fixtureからaarcherの情報を取得
    archer = users(:archer)

    # michaelがarcherをフォローしてないことを確認
    assert_not michael.following?(archer)
    # mivhaelがarcherをフォローする
    michael.follow(archer)
    # michaelがarcherをフォローしていることを確認
    assert michael.following?(archer)
    # michaelがarcherをフォロー解除する
    michael.unfollow(archer)
    # michaelがarcherをフォローしていないことを確認
    assert_not michael.following?(archer)

  end











end
