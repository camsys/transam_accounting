Rails.application.routes.draw do

  resources :general_ledger_mappings
  resources :funding_sources, :path => :funding_programs do
    collection do
      get 'details'
      get 'find_fiscal_year_range'
    end
    resources :comments
    resources :documents
  end

  resources :grants do
    resources :grant_apportionments
    resources :grant_amendments

    member do
      get 'summary_info'
      get 'fire_workflow_event'
    end
  end



  resources :general_ledger_accounts do
    collection do
      get 'get_accounts'
      get 'check_grant_budget'
      get 'toggle_archive'
    end
  end

  resources :inventory, :only => [], :controller => 'assets' do
    collection do
      get 'get_general_ledger_account'
    end

    member do
      get 'get_book_value_on_date'
      get 'get_depreciation_months_left'
      get 'edit_depreciation'
      post 'update_depreciation'
    end

    resources :expenditures
  end

  resources :expenditures, :only => [] do
    resources :comments
    resources :documents
  end
end