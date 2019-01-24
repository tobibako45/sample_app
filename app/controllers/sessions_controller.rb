class SessionsController < ApplicationController

  def new
    # debugger
  end

  def create
    # ユーザーをemailで検索する
    user = User.find_by(email: params[:session][:email].downcase)

    # 有効化されたユーザーか判定する
    # .authenticateは、入力されたパスワードを暗号化し、DBに登録されているpassword_digestと一致するか検証します。
    if user && user.authenticate(params[:session][:password])

      # ユーザーが有効化されているとき
      if user.activated?
        # ログインする
        log_in user
        # セッションパラメータのremember_meの値が1なら、ユーザ情報を記憶する（1以外なら忘れる）
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)

        #  フレンドリーフォワーディング
        # 記憶したURL（もしくはデフォルト値）にリダイレクト。ログイン前にユーザーがいた場所にリダイレクトするてこと
        redirect_back_or user
      else
        # アカウントが認証されていない旨のメッセージを代入
        message = "Account not activated. " # アカウントが有効になっていません

        # emailの有効化リンクをチェックする旨のメッセージを代入
        message += "Check your email for the activation link."  # アクティベーションリンクについてはあなたのEメールをチェックしてください。

        # フラッシュメッセージにwarningをセットする
        flash[:warning] = message
        # ルートURLにリダイレクトする
        redirect_to root_url

      end


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
