FactoryGirl.define do

  factory :chart_of_account do
    association :organization
    active true
  end

end
