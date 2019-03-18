FactoryGirl.define do

  factory :grant do
    association :owner, factory: :organization
    association :sourceable, factory: :funding_source
    sequence(:grant_num) {|n| "Grant#{n}"}
    fy_year { Date.today.year }
    amount { 50000 }
    award_date { Date.today }
  end

end
