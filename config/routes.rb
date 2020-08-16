Rails.application.routes.draw do

  
  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', password: 'password', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'sign_up' },
                       controllers: { :registrations => "registrations" }, skip: :omniauth_callbacks

    devise_scope :user do
      get 'register', to: 'devise/registrations#new', as: :sign_up
    end

    root "users#newsfeed"
    
    resources :users do
      member do
        get :following, :followers
        post :follow
        get :posts
        get :newsfeed
        post :create_post
      end
    end
    get "/search", to: 'users#search'
    
  end

  devise_for :users, skip: [:session, :password, :registration], controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
end
