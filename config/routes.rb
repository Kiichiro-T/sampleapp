Rails.application.routes.draw do
  get 'receipt_pdfs/index', to: 'receipt_pdfs#index'
  devise_for :users
  root 'homes#index'
  get 'homes/index'
  #get 'receipt.pdf', to: 'receipt_pdf#index'
  resources :events do
    resources :transactions
  end

end
