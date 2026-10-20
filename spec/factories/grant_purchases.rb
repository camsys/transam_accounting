FactoryGirl.define do

  factory :grant_purchase do
    association :sourceable, :factory => :funding_source
    association :transam_asset, :factory => :transam_asset
    pcnt_purchase_cost { 100 }
    # funding_source_type_id 1 is federal, which makes fain required
    fain { 'TESTFAIN123' }
  end

end
