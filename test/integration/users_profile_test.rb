require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end


  # プロフィールを表示
  test "profile display" do
    # GETリクエスト送信 プロフィールページ
    get user_path(@user)
    # ユーザープロフィールページ（users/show）のテンプレートが表示されること
    assert_template 'users/show'

    # HTMLのtitle属性にユーザーの名前が表示されること
    assert_select 'title', full_title(@user.name)

    # HTMLのh1タグにユーザーの名前が表示されること
    assert_select 'h1', text: @user.name

    # HTMLのh1タグの下に、imgタグ（gravatorクラス付き）が表示されること
    assert_select 'h1>img.gravatar'

    # ユーザーのマイクロポスト数をカウントして文字列に変換する。レスポンスのHTML内に存在するかチェック
    assert_match @user.microposts.count.to_s, response.body

    # HTMLにdivタグ（paginationクラス付き）が表示されること
    assert_select 'div.pagination'

    # ユーザーのマイクロポストから、paginateを使って１ページ目を取得する。取得した結果を繰り返す
    @user.microposts.paginate(page: 1).each do |micropost|
      # マイクロポストのcontent属性が、レスポンスのHTML内に存在するかチェック
      assert_match micropost.content, response.body
    end

    # div class=paginationが1度のみ表示されていることをテスト
    assert_select 'div.pagination', count:1


  end


end
