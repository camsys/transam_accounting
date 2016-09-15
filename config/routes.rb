Rails.application.routes.draw do

  resources :funding_templates

  resources :expenditures do
    resources :comments
    resources :documents
  end

  resources :general_ledger_accounts

  resources :inventory, :only => [], :controller => 'assets' do
    member do
      get 'edit_depreciation'
      post 'update_depreciation'
    end
  end
end
