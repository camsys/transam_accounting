FactoryGirl.define do

  factory :grant_purchase do
    association :sourceable, :factory => :funding_source
    association :asset, :factory => :buslike_asset
    pcnt_purchase_cost { 100 }
  end

end
