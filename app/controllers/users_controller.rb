class UsersController < ApplicationController

  # 実行前メソッド。フィルタ。まず最初にlogged_in_userメソッドを実行して、ログイン済みユーザーかどうか確認してる。
  # onlyオプションを指定すると、指定したアクションでのみ利用する。
  # これだとeditアクションとupdateアクションだけに適用。indexとdestroyも追加
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  # 正しいユーザーかチェック
  before_action :correct_user, only: [:edit, :update]
  # destroyアクションを管理者だけに限定する
  before_action :admin_user, only: :destroy

  def index
    # @users = User.all
    # @users = User.paginate(page: params[:page])
    # byebug
    @users = User.where(activated: true).paginate(page: params[:page])
  end


  def show
    @user = User.find(params[:id])
    # @micropostsインスタンス変数をshowアクションに追加
    # @microposts = @user.microposts.paginate(page: params[:page])
    @microposts = @user.microposts.paginate(page: params[:page])

    redirect_to root_url and return unless @user.activated?

    # byebug
    # debugger
  end

  def new
    @user = User.new
    # debugger
  end

  def create
    # @user = User.new(params[:user]) これでもいいけど、直でDBに入れると危険なので
    # 外部メソッドにでparamsを受け取ってから入れる
    @user = User.new(user_params)

    if @user.save

      # ユーザーモデルオブジェクトからメールを送信する
      @user.send_activation_email


      # log_in @user

      # ユーザー登録にアカウント有効化を追加する
      # account_activationでアカウント有効化リンクをメール送信する
      # deliver_nowでメールを送信する
      #
      # deliver_nowは、メールを送信するメソッド。
      # アカウント有効化メールを送信後、ログインするのではなく、T
      # OPページにリダイレクトさせる
      # UserMailer.account_activation(@user).deliver_now
      # flash[:success] = "Welcome to the Sample App!"

      flash[:info] = "Please check your email to activate account."
      redirect_to root_url
      # redirect_to @user
      # redirect_to user_url(@user) # 同等
    else
      render 'new'
    end

  end



  def edit
    @user = User.find(params[:id])
  end



  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 更新に成功した場合
      flash[:success] = "Profile updated"
      redirect_to @user # 自身に@userを返す
    else
      render 'edit'
    end
  end


  def destroy
    User.find(params[:id]).destroy # DBから削除 trueが返る
    flash[:success] = "User deleted"
    redirect_to users_url
  end


  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end





  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # beforeアクション


  # ログイン済みユーザーかどうか確認
  # def logged_in_user
  #   # ログインしてなかったら、flashメッセージを出して、ログインページにいく
  #   unless logged_in?
  #     store_location
  #     flash[:danger] = "Please log in."
  #     redirect_to login_url
  #   end
  # end
  #

  # Applicationコントローラに移したので削除


  # 正しいユーザーかどうか確認
  def correct_user
    # paramsのidを取得し、DBからユーザ情報を取得した結果をインスタンス変数@userに代入
    @user = User.find(params[:id])
    # 取得した@user、現在のログイン中のユーザ情報を比較する（sessions_helper.rbで定義したcurrent_userを呼び出す）
    # 一致していない場合は、root_urlにリダイレクトさせる。
    # redirect_to(root_url) unless @user == current_user
    redirect_to(root_url) unless current_user?(@user)
  end


  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end


end
