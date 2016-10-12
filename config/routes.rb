Rails.application.routes.draw do

  resources :buckets do
    collection do
      get 'find_templates_from_program_id'
      get 'find_organizations_from_template_id'
    end
  end


  resources :funding_sources, :path => :funding_programs do
    collection do
      get 'details'
    end
    resources :comments
    resources :documents
  end

  resources :funding_templates

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

  resources :general_ledger_accounts

  resources :inventory, :only => [], :controller => 'assets' do
    member do
      get 'edit_depreciation'
      post 'update_depreciation'
    end
  end
end
