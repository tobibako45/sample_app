require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  # test "indexアクションのリダイレクトをテストする" do
  test "should redirect index when not logged in" do
    get users_path # /usersにアクセス
    assert_redirected_to login_url
  end


  test "should get new" do
    get signup_path
    assert_response :success
  end

  # 間違ったユーザーでログインしたときは編集をリダイレクトするかチェック
  # test "should redirect edit when logged in as wrong user" do
  #   log_in_as(@other_user) # archer(二人目)でログイン
  #   get edit_user_path(@user) # michael(一人目)のページへアクセス
  #   assert flash.empty? # flashメッセージが空かチェック
  #   assert_redirected_to root_url # root_urlにリダイレクト
  # end

  # 間違ったユーザーとしてログインしたときに更新をリダイレクトするかチェック
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user) # 二人目でログイン
    # 1人目のユーザー「michael」のユーザ情報変更画面や、ユーザ情報更新を行う
    patch user_path(@user), params: {
        user: {
            name: @user.name,
            email: @user.email
        }
    }
    assert flash.empty? # flashメッセージが空かチェック
    assert_redirected_to root_url # root_urlにリダイレクト
  end


  # admin属性をWeb経由で通知することを許可しないでください
  test "should not allow the admin attribute to be adited via web" do

    log_in_as(@user) #  # テストユーザーとしてログインする
    assert_not @other_user.admin? # @other_userがあadmin権限でないｋとをチェック
    # @other_userのパスワード、パスワード確認、管理ユーザ属性をtrueに更新する
    patch user_path(@other_user), params: {
        user: {
            password: @other_user.password,
            password_confirmation: @other_user.password_confirmation,
            admin: true
        }
    }
    # @other_userの情報を再読み込みした結果、管理ユーザではないこと
    assert_not @other_user.reload.admin?

  end

  # 指定されていない場合はdestroyをリダイレクトする
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # 管理者以外のユーザーとしてログインした場合は、destroyをリダイレクトする必要があります。
  test "should redirect destroy when logged in as a non-admin" do

    log_in_as(@other_user) # @other_userでログイン
    # countが正しく変化していないことを確認
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end


  # ログインしていないときは、フォローページをリダイレクトする
  test "should redirect following when not logged in" do
    # following_user_pathにGET送信
    get following_user_path(@user)
    # ログインページへリダイレクト
    assert_redirected_to login_url
  end

  # ログインしていないときはフォロワーページをリダイレクトする
  test "should redirect followers when not logged in" do
    # followers_user_pathにGET送信
    get followers_user_path(@user)
    assert_redirected_to login_url
  end


end
