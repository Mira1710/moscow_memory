Rails.application.routes.draw do
  resources :places

  root "home#index"
end