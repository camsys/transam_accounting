# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence :asset_tag do |n|
    "ABS_TAG#{n}"
  end

  trait :basic_asset_attributes do
    association :organization, :factory => :organization
    asset_tag
    purchase_date { 1.year.ago }
    in_service_date { 1.year.ago }
    depreciation_start_date Date.new(2014,1,1)
    manufacture_year "2000"
    fta_funding_type_id 1
    created_by_id 1
  end

  factory :buslike_asset, :class => :asset do # An untyped asset which looks like a bus
    basic_asset_attributes
    asset_type_id 1
    asset_subtype_id 1
    purchase_cost 2000.0
    expected_useful_life 120
    reported_condition_rating 2.0
    #replacement_value 100
    estimated_replacement_cost { 100 }
  end

end
