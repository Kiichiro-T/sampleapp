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
  get 'users/csv_template', to: 'users#csv_template', as: 'csv_template'
  get 'groups/:group_id/users/share', to: 'users#share', as: 'share'
  resources :groups do
    resources :users, only: [:index, :new] do
      collection do
        post :batch
      end
    end
  end
  resources :events do
    resources :transactions, only: [:new, :create]
  end

end
