FactoryGirl.define do

  factory :expenditure do
    association :organization
    association :expense_type
    description 'Test Expenditure Description'
  end

  factory :expense_type do
    association :organization
    name 'Test Expense Type'
    description 'Test Expense Type Description'
    active true
  end
  
end
