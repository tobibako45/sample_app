require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  # test "Sessionsコントローラのテストで名前付きルートを使うようにする" do
  test "should get new" do
    get login_path
    # レスポンスのHTTPステータスコードが一致すれば成功。:success	ステータスコード200
    assert_response :success
  end

end
