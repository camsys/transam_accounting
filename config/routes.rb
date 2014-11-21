Rails.application.routes.draw do

  resources :expenditures

  resources :general_ledger_accounts, :only => [:index, :show]

end
