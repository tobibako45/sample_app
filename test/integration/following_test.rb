require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest


  def setup
    # fixtureからmichaelを取得
    @user = users(:michael)
    # fixtureからarcherを取得
    @other = users(:archer)
    # michaelでログイン
    log_in_as(@user)
  end

  # フォローページのテスト
  test "following page" do
    # following_user_pathにGETリクエスト
    get following_user_path(@user)
    # @userのフォローユーザーが空出ないことを確認
    assert_not @user.following.empty?
    # @userのフォローユーザー数が、HTMLに表示してることを確認
    assert_match @user.following.count.to_s, response.body
    # フォローユーザーの数だけループ
    @user.following.each do |user|
      # フォローユーザーのプロフィールページへのリンクがあることを確認
      assert_select "a[href=?]", user_path(user)
    end
  end


  # フォロワーページのテスト
  test "followers page" do
    # following_user_pathへGETリクエスト
    get followers_user_path(@user)
    # @userのフォロワーユーザーが空でないことを確認
    assert_not @user.followers.empty?
    # @userのフォロワーユーザー数が、HTMLに表示していることを確認
    assert_match @user.followers.count.to_s, response.body
    # フォロワーユーザーの数だけループ
    @user.followers.each do |user|
      # フォロワーユーザーのプロフィールページへのリンクがあることを確認
      assert_select "a[href=?]", user_path(user)
    end
  end


  # ーザーに標準的な方法で従うべき
  test "should follow a user the standard way" do

    # @userに、フォローされた人が1人増えたことを確認
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: {followed_id: @other.id}
    end
  end

  # Ajax版
  test "should follow a user with Ajax" do
    # @userに、フォローされた人が1人増えたことを確認
    assert_difference '@user.following.count', 1 do
      # Ajaxのテストでは、xhr :trueオプションを使う
      post relationships_path, xhr: true, params: {followed_id: @other.id}
    end
  end

  # 標準的な方法でユーザーをフォロー
  test "should unfollow a user the standard way" do
    # @otherをフォロー
    @user.follow(@other)
    # @user.active_relationshipsから、@other.idを検索して代入
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # @userのフォロワーが1人減ったことを確認
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  # Ajax版
  test "should unfollow a user with Ajax" do
    # @otherをフォロー
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other)
    assert_difference '@user.following.count', -1 do
      # Ajaxのテストでは、xhr :trueオプションを使う
      delete relationship_path(relationship), xhr: true
    end

  end




end
