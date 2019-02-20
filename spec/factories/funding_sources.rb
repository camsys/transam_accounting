FactoryGirl.define do

  factory :funding_source do
    sequence(:name) {|n| "Test Funding Source #{n}"}
    description { 'Test Funding Source Description' }
    funding_source_type_id { 1 }
    match_required { 80.0 }
  end

end
