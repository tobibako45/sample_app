require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    # メールを保存する配列をクリアする
    ActionMailer::Base.deliveries.clear
    # michael取得して格納
    @user = users(:michael)
  end


# test " パスワード再設定の統合テスト" do
  test "password resets" do

    # GETを送信。パスワード再セットのページにアクセス
    get new_password_reset_path
    # パスワード再セットのページが表示されるか確認
    assert_template 'password_resets/new'

    # メールアドレスが無効

    # POSTを送信。 メールアドレスは空
    post password_resets_path,
         params: {
             password_reset: {
                 email: ""
             }
         }
    # flashメッセージが表示されることを確認
    assert_not flash.empty?
    # パスワード再セットのページが表示されるか確認
    assert_template 'password_resets/new'


    # メールアドレスが有効

    # post送信。@userのメールアドレス
    post password_resets_path, params: {
        password_reset: {
            email: @user.email
        }
    }
    # @userのreset_digestが、再セット前と後で変わってる事ことをチェック
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # メイラーの配列に保存された件数が１件であることをチェック
    assert_equal 1, ActionMailer::Base.deliveries.size
    # flashメッセージが空でないとこ(表示されること)を確認
    assert_not flash.empty?
    # root_urlにリダイレクトされることをチェック
    assert_redirected_to root_url


    # パスワード再設定フォームのテスト

    # assigns(key = nil)
    # アクションを実行した結果、インスタンス変数に代入されたオブジェクトを取得
    user = assigns(:user) # @userの代わりに、userを今後使用


    # メールアドレスが無効

    # GETリクエストを送信。リセットトークンと空のメールアドレスを送信。
    get edit_password_reset_path(user.reset_token, email: "")
    # root_urlにリダイレクトされたかチェック
    assert_redirected_to root_url


    # 無効なユーザー

    # toggel
    # booleanなカラム名を渡すと、trueとfalse入れ替え。

    # userの有効化フラグを逆転（元に戻す）
    user.toggle!(:activated)
    # GETで。userのリセットトークンとuserのemailを送信。
    get edit_password_reset_path(user.reset_token, email: user.email)
    # root_urlにリダイレクトされたか
    assert_redirected_to root_url
    # userの有効化フラグを逆転（元に戻す）
    user.toggle!(:activated)


    # メールアドレスが有効で、トークンが無効

    # GET送信で、リセットトークンがwrong token、emailがuserのemail
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url


    # メールアドレスもトークンも有効

    # GETで、リセットトークンにuser.reset_token、メールアドレスにuser.email
    get edit_password_reset_path(user.reset_token, email: user.email)

    # パスワード再設定画面のテンプレートが表示されること(password_resets/edit)
    assert_template 'password_resets/edit'

    # 画面のHTMLに、
    # input
    # name=email
    # type=hidden
    # value:user.email
    # が、表示されていること
    assert_select "input[name=email][type=hidden][value=?]", user.email


    # 無効なパスワードとパスワード確認

    # PATCHリクエストを送信する。（password_reset_path）
    # email: user.email
    # user
    #  password: foobaz
    #  password_confirmation: barquux
    patch password_reset_path(user.reset_token),
          params: {
              email: user.email,
              user: {
                  password: "foobaz",
                  password_confirmation: "barquux"
              }
          }

    # 画面に以下のHTMLが表示されていること（エラーになる）
    # div#error_explanation
    assert_select 'div#error_explanation'


    # パスワードが空

    # PATCHを送信
    # email:user.email
    # user
    #  password: 空
    #  password_confirmation: 空
    patch password_reset_path(user.reset_token),
          params: {
              email: user.email,
              user: {
                  password: "",
                  password_confirmation: ""
              }
          }

    # 画面に以下のHTMLが表示されていること（エラーになる）
    # div#error_explanation
    assert_select 'div#error_explanation'


    # 有効なパスワードとパスワード確認

    # PATCH送信
    # email: user.email
    # user
    #  password: foobaz
    #  password_confirmation: foobaz
    patch password_reset_path(user.reset_token),
          params: {
              email: user.email,
              user: {
                  password: "foobaz",
                  password_confirmation: "foobaz"
              }
          }


    # パスワードの再設定に成功後、user.reload後のreset_digest属性がnilになっていることを確認する。
    assert_nil user.reload.reset_digest


    # ログイン状態なことを確認
    assert is_logged_in?
    # flashメッセージが空でないことを確認(成功メッセージが表示)
    assert_not flash.empty?
    # ユーザープロフィール画面へリダイレクト
    assert_redirected_to user


  end


# test "パスワード再設定の期限切れテスト" do
  test "expired tokens" do

    # GETリクエストで送信する
    get new_password_reset_path
    # POSTリクエストで送信する
    post password_resets_path,
         params: {
             password_reset: {
                 email: @user.email
             }
         }

    # パスワード再設定フォームのテストのために、アクションを実行結果、インスタンス変数に代入されたオブジェクトを取得

    # @userにassigns(:user)の結果を代入
    @user = assigns(:user)
    # パスワード再設定メール送信時間を３時間前に更新
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    # patchリクエストを送信
    patch password_reset_path(@user.reset_token),
          params: {
              email: @user.email,
              user: {
                  password: "foobar",
                  password_confirmation: "foobar"
              }
          }
    # レスポンスが302であることを確認
    assert_response :redirect
    # 単一のリダイレクトのレスポンスに従う
    follow_redirect!
    # レスポンスで返されたHTMLの中身に、expired(期限切れ)の文字があることを確認
    assert_match /expired/i, response.body

  end


end
