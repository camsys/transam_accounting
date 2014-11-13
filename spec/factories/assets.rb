# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence :asset_tag do |n|
    "ABS_TAG#{n}"
  end

  trait :basic_asset_attributes do
    association :organization, :factory => :organization
    asset_tag
    purchase_date { 1.year.ago }
    manufacture_year "2000"
    created_by_id 1
  end

  factory :buslike_asset, :class => :asset do # An untyped asset which looks like a bus
    basic_asset_attributes
    association :asset_type
    association :asset_subtype
    purchase_cost 2000.0
    expected_useful_life 10
    reported_condition_rating 2.0
    property_type true
    book_value 100
    salvage_value 100
    #replacement_value 100
    estimated_replacement_cost { 100 }
  end

end