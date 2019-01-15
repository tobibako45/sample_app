require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest


  def setup
    ActionMailer::Base.deliveries.clear
  end

  # assert_difference
  # ブロックの最初と最後で、expressionsの式の結果に、differenceの差異が発生すれば成功。
  # differenceのデフォルトは1。
  # assert_no_differenceはその逆

  # test "無効なユーザー登録に対するテスト" do
  test "invalid signup informatoin" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: {user: {name: "",
                                       email: "user@invalid",
                                       password: "foo",
                                       password_confirmation: "bar"}}
    end
    assert_template 'users/new' # 指定するビューテンプレートを利用して描画されたら成功。
    # selectorでCSSセレクタを記述する。
    # CSSセレクタの要素が一致すれば成功。
    assert_select 'div#error_explanation' #idがerror_explanationがあれば成功
    assert_select 'div.field_with_errors'
    # assert_select 'div.alert' # .alertがあれば成功
    # assert_select 'form[action="/signup"]'
  end


  # test "有効なユーザー登録に対するテスト" do
  # test "valid signup information" do

  # ユーザー登録のテストにアカウント有効化を追加する
  test "valid signup information with account activation" do
    # GETでsignup_pathにアクセスする
    get signup_path
    # User.countが1増えていること
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # 配信されたメッセージが1と等しいか確認
    assert_equal 1, ActionMailer::Base.deliveries.size
    # createアクション内のインスタンス変数@userにアクセスしてユーザー情報を取得する
    user = assigns(:user)
    # ユーザーが有効化されていないことを確認
    assert_not user.activated?
    # （有効化されていない状態で）ログインする
    log_in_as(user)
    # ログインできないことを確認
    assert_not is_logged_in?
    # GETでedit_account_activation_pathにアクセスする。引数１：無効なトークン 引数２：ユーザーのemail
    get edit_account_activation_path("invalid toke", email: user.email)
    # ログインできないことを確認
    assert_not is_logged_in?
    # GETでedit_account_activation_pathにアクセスする。引数１：ユーザーの有効化トークン 引数２：不正なemail
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    # ログインできないことを確認
    assert_not is_logged_in?
    # GETでedit_account_activation_pathにアクセスする。引数１：ユーザーの有効化トークン 引数２：ユーザーのemail
    get edit_account_activation_path(user.activation_token, email: user.email)
    # ユーザーをDBから再読み込みして、有効化されていることを確認
    assert user.reload.activated?
    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    # ユーザープロフィール画面のテンプレートが表示されること
    assert_template 'users/show'
    # ログインできることを確認
    assert is_logged_in?


    # そのアクションで指定されたテンプレートが描写されているかを検証
    # assert_template 'users/show'

    # flash.empty?が偽なら成功。flashメッセージが空でなければ成功
    # assert_not flash.empty?

    # is_logget_in?が真ならば成功
    # assert is_logged_in?
  end

end
