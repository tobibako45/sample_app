require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    # fixtureサンプルユーザーを設定
    @user = users(:michael)

# このコードは慣習的に正しくない
#     @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)

# 慣習的に正しくmicropostを作成する
    @micropost = @user.microposts.build(content: "Lorem ipsum")

  end


  # 有効であるべき
  test "should be valid" do
    assert @micropost.valid?
  end

  # user_idが存在するはず
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # contentが存在するはず
  test "content should be present" do
    @micropost.content = " "
    assert_not @micropost.valid?
  end

  # contentは最大140文字です
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end


  # 順番は最新のものから
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end


end
