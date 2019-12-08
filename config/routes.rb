Rails.application.routes.draw do
  # get 'receipt_pdfs/index', to: 'receipt_pdfs#index'
  devise_for :users
  root 'homes#index'
  get 'homes/index'
  get 'events/:event_id/transactions/:id', to: 'receipt_pdfs#show', as: 'pdf'
  resources :events do
    resources :transactions, only: [:new, :create]
  end

end
