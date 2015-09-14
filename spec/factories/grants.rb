FactoryGirl.define do

  factory :grant do
    association :organization
    association :funding_source
    fy_year Date.today.year
    grant_number 'GRANT-XX-123456'
    amount 50000
  end

end
