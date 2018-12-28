require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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
    assert_select 'div.alert' # .alertがあれば成功
    assert_select 'form[action="/signup"]'
  end

  # test "有効なユーザー登録に対するテスト" do
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect! # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    assert_template 'users/show'

    assert_not flash.empty? # flashメッセージが空でなければ成功
  end

end
