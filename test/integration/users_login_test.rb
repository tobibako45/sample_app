require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # test "フラッシュメッセージの残留をキャッチするテスト" do
  test "login with invalid information" do
    # ログイン用のパスを開く
    get login_path
    # 新しいセッションのフォームが正しく表示されたことをチェック
    assert_template 'sessions/new'
    # わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: { session: { email: "", password: "" } }
    # 新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることをチェック
    assert_not flash.empty?
    # 別のページ (Homeページなど) にいったん移動
    get root_path
    # 移動先のページでflashが表示されていないことをチェック
    assert flash.empty?
  end


  # 有効な情報を使ってユーザーログインをテストする
  # test "有効な情報でログインし、その後ログアウトする" do
  test "login with valid information followed by logout" do
    # ログイン用のパスを開く
    get login_path
    # セッション用に有効な情報をpostする
    post login_path, params: { session: { email: @user.email, password: 'password' } }

    # ユーザーログアウトのテスト
    assert is_logged_in?

    # リダイレクトが正しいかチェック
    assert_redirected_to @user
    # そのページの移動
    follow_redirect!
    # ログイン用のリンクがなくなってるかをチェック
    assert_template 'users/show'
    # count: 0というオプションをassert_selectに追加すると、渡したパターンに一致するリンクが０かどうかを確認するようになる。
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # logoutのチェック
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # assert_not_empty cookies['remember_token']
    # assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remembering" do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end

end
