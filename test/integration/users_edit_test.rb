require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  #  編集の失敗に対するテスト
  test "unsuccessful edit" do
    # before_actionがあるため、テストユーザーとしてログインする
    log_in_as(@user)
    get edit_user_path(@user) # アクセス
    assert_template 'users/edit' # 表示チェック
    # PATCHリクエストのチェック
    patch user_path(@user), params: {
        user: {
            name: "",
            email: "foo@invalid",
            password: "foo",
            password_confirmation: "bar"
        }
    }
    assert_template 'users/edit' # 戻ってきた表示のチェック
  end

  # 編集の成功に対するテスト
  # test "successful edit" do
  #   # before_actionがあるため、テストユーザーとしてログインする
  #   log_in_as(@user)
  #   get edit_user_path(@user) # edit_user_pathにアクセス
  #   assert_template 'users/edit'  # テンプレートの描写チェック
  #   name = "Foo bar" # 設定
  #   email = "foo@bar.com" # 設定
  #   # patchリクエストのチェック
  #   patch user_path(@user), params: {
  #       user: {
  #           name: name,
  #           email: email,
  #           password: "",
  #           password_confirmation: ""
  #       }
  #   }
  #   assert_not flash.empty? # flashメッセージが空じゃないことをチェック
  #   assert_redirected_to @user # リダイレクトをチェック
  #   @user.reload # DBから最新のユーザー情報をレロードされてるかチェック
  #   assert_equal name, @user.name # 変数1と変数2が等しければ成功
  #   assert_equal email, @user.email # emailと@user.emailが等しいかチェック
  # end

  # フレンドリーフォワーディングのテスト
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    # session[:forwarding_url]とedit_user_url(@user)が等しいかチェック
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    assert_nil session[:forwarding_url]
    name = "Foo bar" # 設定
    email = "foo@bar.com" # 設定
    # patchリクエストのチェック
    patch user_path(@user), params: {
        user: {
            name: name,
            email: email,
            password: "",
            password_confirmation: ""
        }
    }
    assert_not flash.empty? # flashメッセージが空じゃないことをチェック
    assert_redirected_to @user # リダイレクトをチェック
    @user.reload # DBから最新のユーザー情報をレロードされてるかチェック
    assert_equal name, @user.name # 変数1と変数2が等しければ成功
    assert_equal email, @user.email # emailと@user.emailが等しいかチェック
  end




end
