Rails.application.routes.draw do
  devise_for :users
  root 'homes#index'
  get 'homes/index'
  resources :events
end
