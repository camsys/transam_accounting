FactoryGirl.define do

  factory :grant do
    association :organization
    association :sourceable, factory: :funding_source
    sequence(:name) {|n| "Grant#{n}"}
    fy_year Date.today.year
    amount 50000
  end

end
