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
  get 'events/:event_id/transactions/:id/receipt', to: 'receipt_pdfs#show', as: 'pdf'
  get 'users', to: 'users#index', as: 'users'
  resource :users, only: [:new] do
    collection do
      post :batch
    end
  end
  resources :groups
  resources :events do
    resources :transactions, only: [:new, :create]
  end

end
