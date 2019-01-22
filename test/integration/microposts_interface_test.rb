require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end


  test "micropost interface" do
    # ログイン
    log_in_as(@user)
    # root_pathへGETリクエスト
    get root_path
    # HTMLにdiv.paginationがあることを確認
    assert_select 'div.pagination'
    # HTMLに、input type=fileがあることを確認
    assert_select 'input[type=file]'


    # 無効な送信

    # マイクロポストの数が変わることを確認
    assert_no_difference 'Micropost.count' do
      # microposts_pathへPOST送信
      post microposts_path, params: {micropost: {content: ""}}
    end
    # HTMLにdiv error_explanationがあることを確認
    assert_select 'div#error_explanation'


    # 有効な送信

    # 変数contentに文字列を代入
    content = "This micropost really ties the room together このマイクロポストは本当に部屋をつなぎます"
    # fixtureディレクトリにある、rails.pngを、image/pngにアップロードして、picture変数の代入
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    # マイクロポストの数が変わることを確認
    assert_difference 'Micropost.count', 1 do
      # microposts_pathへPOST送信
      post microposts_path, params: {
          micropost: {
              content: content,
              picture: picture # picture変数を引数に追加して投稿できることを確認
          }
      }
    end

    # root_urlへリダイレクトされること
    assert_redirected_to root_url

    # リダイレクトを追う
    #follow_redirect!は、POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    #代入したcontentの文字が、HTML内に一致すること
    assert_match content, response.body


    # 投稿を削除する

    # HTML内にdeleteテキストと、aタグがあることを確認
    assert_select 'a', text: 'delete'
    # 1番目のユーザーのマイクロソフトであることを確認
    first_micropost = @user.microposts.paginate(page: 1).first
    # マイクロソフトの数が-1されることを確認
    assert_difference 'Micropost.count', -1 do
      # micropost_pathへdeleteリクエストを送信
      delete micropost_path(first_micropost)
    end


    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）

    # archerユーザーのプロフィールへGET送信
    get user_path(users(:archer))
    # HTML内にdeleteテキストとaタグが0件であることを確認
    assert_select 'a', text: 'delete', count: 0

  end


# サイドバーでマイクロポストの投稿数をテストするためのテンプレート
#   test "micropost sidebar count" do
#     # テストユーザー(michael)としてログイン
#     log_in_as(@user)
#     # root_pathへGETリクエスト
#     get root_path
#     # michaelのマイクロソフト数をカウントして、複数形で表示されることを確認
#     assert_match "#{@user.microposts.count} microposts", response.body
#
#     # まだマイクロソフトを投稿していないユーザー
#     other_user = users(:malory)
#     # 別ユーザー(malory)でログイン
#     log_in_as(other_user)
#     # root_pathでGET送信
#     get root_path
#     # HTMLに"0 micropost"と単数形で表示されることを確認
#     assert_match "0 microposts", response.body
#     # maloryでマイクロポストを投稿する
#     other_user.microposts.create!(content: "A micropost")
#     # root_pathへGET送信
#     get root_path
#     # HTMLに"1 micropost"と単数形で表示されることを確認
#     assert_match "1 micropost", response.body
#   end


end
