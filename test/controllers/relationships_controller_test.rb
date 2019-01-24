require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # 作成にはログインユーザが必要です
  test "create should require logged-in user" do
    # Relationship.countが変わらないことを確認
    assert_no_difference 'Relationship.count' do
      # relationships_pathにPOSTリクエスト送信
      post relationships_path
    end
    # ログイン画面へリダイレクトされるのを確認
    assert_redirected_to login_url
  end


  # 削除するにはログインユーザーが必要です
  test "destroy should require logged-in user" do
    # Relationship.countが変わらないことを確認
    assert_no_difference 'Relationship.count' do
      # relationship_pathにdeleteリクエスト
      # fixtureのrelationship内の:oneを削除
      delete relationship_path(relationships(:one))
    end
    # ログイン画面へリダイレクトされるのを確認
    assert_redirected_to login_url
  end



end
