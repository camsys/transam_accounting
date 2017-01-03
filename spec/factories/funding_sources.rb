FactoryGirl.define do

  factory :funding_source do
    name 'Test Funding Source'
    description 'Test Funding Source Description'
    funding_source_type_id 1
    match_required 80.0
  end

end
