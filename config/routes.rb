Rails.application.routes.draw do
  post "launch_subscriptions", to: "launch_subscriptions#create", as: :launch_subscriptions

  namespace :admin do
    get "/", to: "places#index", as: :root
    get "login", to: "sessions#new", as: :login
    post "login", to: "sessions#create", as: :session
    delete "logout", to: "sessions#destroy", as: :logout
    get "setup", to: "sessions#setup", as: :setup
    post "setup", to: "sessions#create_owner"
    get "map", to: "sections#map", as: :map
    get "routes", to: "sections#routes", as: :walking_routes
    get "forum", to: "sections#forum", as: :forum
    get "about", to: "sections#about", as: :about
    get "profile", to: "sections#profile", as: :profile
    resources :profile_submissions, only: [ :index, :update ]
    resources :launch_subscriptions, only: :index
    resources :places
  end

  resources :places

  get "routes", to: "pages#routes", as: :walking_routes
  get "articles", to: "pages#articles", as: :articles
  get "forum", to: "pages#forum", as: :forum
  get "about", to: "pages#about", as: :about
  get "profile", to: "user_accounts#show", as: :profile
  patch "profile", to: "user_accounts#update"
  get "register", to: "user_accounts#new", as: :user_registration
  post "register", to: "user_accounts#create"
  get "login", to: "user_accounts#login_form", as: :user_login
  post "login", to: "user_accounts#login"
  delete "logout", to: "user_accounts#logout", as: :user_logout
  resources :profile_submissions, only: [ :new, :create ]
  resources :saved_routes, only: [ :create, :destroy ]
  resources :saved_places, only: [ :create, :destroy ]

  root "home#index"
end
