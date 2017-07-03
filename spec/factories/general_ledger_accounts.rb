FactoryGirl.define do

  factory :general_ledger_account do
    association :chart_of_account
    general_ledger_account_type_id 1
    general_ledger_account_subtype_id 1
    account_number 'GLA-XX-123456'
    name 'Test GLA'
    active true
  end

end
