Rails.application.routes.draw do

  resources :general_ledger_accounts, :only => [:index, :show]

end
