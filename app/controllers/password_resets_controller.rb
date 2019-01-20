class PasswordResetsController < ApplicationController

  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  # パスワード再設定の有効期限が切れていないか
  before_action :check_expiration, only: [:edit, :update]


  def new
  end

  def create
    # メールアドレスをキーにしてユーザーをDBから見つける
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # パスワード再設定用トークンと、送信時のタイムスタンプでDBの属性を更新する
      @user.create_reset_digest
      # パスワード再設定用トークンと、送信時のタイムスタンプでDBの属性を更新する
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      # ルートURLにリダイレクトする
      redirect_to root_url
    else
      # flash.nowメッセージを表示する
      flash.now[:danger] = "Email address not found"
      # newページを表示
      render 'new'
    end
  end

  def edit
  end

  def update
    # 新しいパスワードが空文字列になっていないか (ユーザー情報の編集ではOKだった)
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'

    elsif @user.update_attributes(user_params) # 新しいパスワードが正しければ、更新する

      # 渡されたユーザーでログインする
      log_in @user
      # パスワード再設定が成功したらダイジェストをnilにする
      @user.update_attribute(:reset_digest, nil)

      flash[:success] = "Password has been reset. パスワードがリセットされました。"
      redirect_to @user

    else
      render 'edit' # 無効なパスワードであれば失敗させる (失敗した理由も表示する)
    end
  end




  private


  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end


  # beforeフィルタ

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーの定義は以下の通り。
  #
  # ユーザーが存在すること
  # 有効化されていること
  # 認証済みであること
  # 満たさない場合は、ルートURLにリダイレクトする。
  def valid_user
    unless (@user && @user.activated? &&
        @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end


  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired.  パスワードのリセット期限が切れました。"
      redirect_to new_password_reset_url
    end
  end




end
