FactoryGirl.define do

  factory :grant_purchase do
    association :grant
    association :asset, :factory => :buslike_asset
    pcnt_purchase_cost 100
  end

end
