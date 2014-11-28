Rails.application.routes.draw do

  resources :expenditures

  resources :general_ledger_accounts, :only => [:index, :show]

  resources :inventory, :only => [], :controller => 'assets' do
    member do
      get 'edit_depreciation'
      post 'update_depreciation'
    end
  end
end
