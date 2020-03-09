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
      resources :transactions, only: [:index], param: :url_token
    end
    resources :events, only: %i[new create show edit update]

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

  resources :users, only: [:show] do
    resources :transactions, only: [:index]
  end

  resources :events, only: [] do
    resources :transactions, only: %i[index new create edit update], controller: 'events/transactions', param: :url_token do
      member do
        get :receipt, to: 'receipt_pdfs#show'
      end
    end
    resources :answers, only: %i[create update]
  end
end
