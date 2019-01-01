class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user
      # Railsでは上のコードを自動的に変換して、次のようなプロフィールページへのルーティングにしています。user_url(user)
      redirect_to user

    else
      # エラーメッセージを作成する
      flash.now[:daner] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end
