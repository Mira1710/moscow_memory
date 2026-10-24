Rails.application.routes.draw do
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
    resources :places
  end

  resources :places

  get "routes", to: "pages#routes", as: :walking_routes
  get "articles", to: "pages#articles", as: :articles
  get "forum", to: "pages#forum", as: :forum
  get "about", to: "pages#about", as: :about
  get "profile", to: "pages#profile", as: :profile

  root "home#index"
end