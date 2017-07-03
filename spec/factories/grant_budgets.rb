FactoryGirl.define do

  factory :grant_budget do
    association :general_ledger_account
    association :grant
    amount 10000
  end

end
