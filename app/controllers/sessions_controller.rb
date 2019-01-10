class SessionsController < ApplicationController

  def new
    # debugger
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in @user

      # [remember me] チェックボックスの送信結果を処理する
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)

      #  フレンドリーフォワーディング
      # 記憶したURL（もしくはデフォルト値）にリダイレクト
      redirect_back_or @user

      # ログインしてユーザーを保持する
      # remember user

      # Railsでは上のコードを自動的に変換して、次のようなプロフィールページへのルーティングにしています。user_url(user)
      # redirect_to user

    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
