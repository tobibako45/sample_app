require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael) # 管理者ユーザ
    @non_admin = users(:archer) # 非管理者ユーザ
    # @non_activated_user = users(:non_activated) # 有効化されていないテストユーザー
  end

  # ページネーションを含めたUsersIndexのテスト
  # test "index including paginate" do
  #   log_in_as(@user) # テストユーザーとしてログインする
  #   get users_path # アクセスする
  #   assert_template 'users/index' # 描写チェック
  #   assert_select 'div.pagination' # 描写されるHTMLの内容をチェック
  #   User.paginate(page: 1).each do |user|
  #     assert_select 'a[href=?]', user_path(user), test: user.name
  #   end
  # end

  # 削除リンクとユーザー削除に対する統合テスト
  test "should as admin including pagination and delete links" do
    log_in_as(@admin) # テスト管理者でログイン
    get users_path # GETリクエストを送信する（ユーザー一覧）
    assert_template 'users/index' # ユーザー一覧のテンプレートが表示されること
    assert_select 'div.pagination' # ‘div.pagination'が表示されること

    # １ページ目のユーザー（30ユーザー）を取得
    first_page_of_users = User.paginate(page: 1)
    # 繰り返し処理を行う
    first_page_of_users.each do |user|
      # ユーザー名と、ユーザーページへのリンク属性が表示されること
      assert_select 'a[href=?]', user_path(user), text: user.name
      # 管理者ユーザーでなければ、deleteリンクが表示されること
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    # ユーザーの件数が-1されていること
    assert_difference 'User.count', -1 do
      # DELETEリクエストを非管理者ユーザーに送信
      delete user_path(@non_admin)
    end

  end


  # 非管理者としての
  test "index as non-admin" do
    log_in_as(@non_admin)  # 非管理者ユーザーでログインする
    get users_path # GETリクエストを送信する（ユーザー一覧）

    # 画面にaタグと、deleteのテキストが表示されないこと
    assert_select 'a', text: 'delete', count: 0
  end


end
