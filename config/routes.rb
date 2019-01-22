Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  # get 'sessoions/new'

  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  # sessions
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users
  # resources :usersという行は、ユーザー情報を表示するURL (/users/1) を追加するためだけのものではありません。
  # サンプルアプリケーションにこの１行を追加すると、ユーザーのURLを生成するための多数の名前付きルートと共に、
  # RESTfulなUsersリソースで必要となるすべてのアクションが利用できるようになるのです。(())
  #

  # アカウント有効化に使うリソース (editアクション)
  resources :account_activations, only: [:edit]

  resources :password_resets,     only: [:new, :create, :edit, :update]

  # マイクロポストリソースのルーティング
  resources :microposts, only: [:create, :destroy]

end
