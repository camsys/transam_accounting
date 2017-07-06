Rails.application.routes.draw do

  resources :funding_sources, :path => :funding_programs do
    collection do
      get 'details'
    end
    resources :comments
    resources :documents
  end

  resources :grants do
    member do
      get 'summary_info'
    end
    resources :comments
    resources :documents
  end

  resources :expenditures do
    resources :comments
    resources :documents
  end

  resources :general_ledger_accounts do
    collection do
      get 'check_grant_budget'
    end
  end

  resources :inventory, :only => [], :controller => 'assets' do
    collection do
      get 'get_general_ledger_account'
    end

    member do
      get 'edit_depreciation'
      post 'update_depreciation'
    end
  end
end