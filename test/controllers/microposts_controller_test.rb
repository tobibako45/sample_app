require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    # テストデータを代入
    @micropost = microposts(:orange)
  end


  # ログインしていないときはcreateをリダイレクトする
  test "should redirect create when not logged in" do

    # micropostsモデルの数をカウントして、変化してないことをチェック
    # ブロック実行前後でexpressionsの値が変わっていなければ成功
    assert_no_difference 'Micropost.count' do
      # POST送信
      post microposts_path, params: {
          micropost: {
              content: "Lorem ipsum"
          }
      }
    end


    # ログイン画面にリダイレクト
    assert_redirected_to login_url

  end


  # ログインしていないときはdestroyをリダイレクトするべき
  test "should redirect destroy when not logged in" do

    # micropostsモデルの数をカウントして、変化してないことをチェック
    assert_no_difference 'Micropost.count' do
      # DELETEリクエストを送信する
      delete micropost_path(@micropost)
    end
    # ログイン画面にリダイレクト
    assert_redirected_to login_url
  end


  # 間違ったユーザーによるマイクロポスト削除に対してテスト
  test "should redirect destroy for wrong micropost" do

    # michaelとしてログイン
    log_in_as(users(:michael))
    # fixtureのantsを取得する
    micropost = microposts(:ants)
    # マイクロポストの件数が変わらないことを確認
    assert_no_difference 'Micropost.count' do
      # マイクロポストを削除する
      delete micropost_path(micropost)
    end
    # root_urlにリダイレクトすることを確認
    assert_redirected_to root_url

  end


end
