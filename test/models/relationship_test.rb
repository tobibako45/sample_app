require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    # Relationshipモデルを生成（follower_id: michael, followed_id: archer）
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end


  # 有効であるべき
  test "should be valid" do
    # @relationshipが有効であること
    assert @relationship.valid?
  end


  # follower_idが必要
  test "should require a follower_id" do
    # @relationshipのfollower_idにnilを代入
    @relationship.follower_id = nil
    # @relationshipが有効でないこと
    assert_not @relationship.valid?
  end

  # follow_idが必要
  test "should reqire a followed_id" do
    # @relationshipのfollowed_idにnilを代入
    @relationship.followed_id = nil
    # @relationshipが有効でないこと
    assert_not @relationship.valid?
  end


end
