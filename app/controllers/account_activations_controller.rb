class AccountActivationsController < ApplicationController

# アカウントを有効化するeditアクション
  def edit
    # ユーザーをemailで検索する
    user = User.find_by(email: params[:email])

    # ユーザーが存在する、かつ、有効化されていないユーザー、かつ、有効化トークンによる認証ができる
    if user && !user.activated? && user.authenticated?(:activation, params[:id])

      # # 有効化ステータスをtrueに更新する
      # user.update_attribute(:activated, true)
      # user.update_attribute(:activated_at, Time.zone.now)

      # ユーザーモデルオブジェクト経由でアカウントを有効化する
      user.activate


      # ユーザーをログイン状態にする
      log_in user
      # フラッシュメッセージにsuccessをセットする
      flash[:success] = "Account activated!"
      # ユーザー情報ページへリダイレクトする
      redirect_to user
    else
      # フラッシュメッセージにdangerをセットする
      flash[:danger] = "Invalid activation link"
      # ルートURLにリダイレクトする
      redirect_to root_url
    end
  end

end
