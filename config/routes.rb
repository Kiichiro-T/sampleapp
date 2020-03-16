# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
Rails.application.routes.draw do
  # get 'receipt_pdfs/index', to: 'receipt_pdfs#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_out', to: 'users/sessions#destroy'
  end

  mount Sidekiq::Web => '/sidekiq'

  root 'homes#index'
  get 'homes/index'
  get 'users/csv_template', to: 'users#csv_template', as: 'csv_template'
  # get 'groups/:group_id/users/share', to: 'users#share', as: 'share'
  resources :groups do
    resources :users, only: [:new] do
      collection do
        post :batch
        get  :share
      end
    end
    resources :events, only: %i[index new create show edit update]

    member do
      get :dashboard
      get :deposit
      get :statistics
      post :inherit
      post :assign
      get :resign
    end

    # resources :transactions, only: [:index, :new, :create, :edit, :update], controller: 'groups/transactions'
    # しばらく実装しない
  end

  resources :users, only: [] do
    resources :transactions, only: [:index]
  end

  resources :events, only: [] do
    resources :transactions, only: %i[new create edit update], controller: 'events/transactions', param: :url_token do
      member do
        get :receipt, to: 'receipt_pdfs#show'
      end
    end
    resources :answers, only: %i[index create update]
  end

  resources :orders, only: [:index]
  post 'orders/submit', to: 'orders#submit'
  post 'orders/paypal/create_payment', to: 'orders#paypal_create_payment', as: :paypal_create_payment
  post 'orders/paypal/execute_payment', to: 'orders#paypal_execute_payment', as: :paypal_execute_payment
  post 'orders/paypal/create_subscription', to: 'orders#paypal_create_subscription', as: :paypal_create_subscription
  post 'orders/paypal/execute_subscription', to: 'orders#paypal_execute_subscription', as: :paypal_execute_subscription
end
