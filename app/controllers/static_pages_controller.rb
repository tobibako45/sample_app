class StaticPagesController < ApplicationController

  # .new
  # モデルオブジェクトを生成する。
  # 保存はまだされていないため、saveメソッドなどを使って保存する。
  # 生成と同時に保存したい場合は、createメソッドを使用する。
  #
  # .build
  # newメソッドのAlias

  def home

    # ログインしてたら
    # @micropost = current_user.microposts.build if logged_in?
    if logged_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end

  end

  def help
  end

  def about
  end

  def contact

    puts 'tete'

  end

end
