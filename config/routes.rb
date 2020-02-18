Rails.application.routes.draw do
  # get 'receipt_pdfs/index', to: 'receipt_pdfs#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  devise_scope :user do
    get "sign_in", to: "users/sessions#new"
    get "sign_out", to: "users/sessions#destroy" 
  end

  root 'homes#index'
  get 'homes/index'
  get 'users/csv_template', to: 'users#csv_template', as: 'csv_template'
  #get 'groups/:group_id/users/share', to: 'users#share', as: 'share'
  resources :groups do
    resources :users, only: [:index, :new] do
      collection do
        post :batch
        get  :share
      end
    end
    resources :events, only: [:index, :new, :create, :show, :edit, :update]

    member do
      get :deposit
      get :statistics
      get :dashboard
      post :inherit
      post :assign
      get :resign
    end

    # resources :transactions, only: [:ibdex, :new, :create, :edit, :update], controller: 'groups/transactions' 
    # しばらく実装しない
  end
  resources :users, only: [:show] do
    resources :transactions, only: [:index], param: :url_token
  end

  resources :events, only: [:index] do
    resources :transactions, only: [:index, :new, :create,:edit, :update], controller: 'events/transactions', param: :url_token do
      member do
        get :receipt, to: 'receipt_pdfs#show'
      end
    end
  end
end
