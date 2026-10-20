FactoryGirl.define do

  # Survivor-hierarchy asset (TransamAsset). Replaces the legacy :buslike_asset for
  # new specs; :buslike_asset (legacy Asset) is left alone until TTPLAT-3070.
  factory :transam_asset do
    sequence(:asset_tag) { |n| "TA_TAG#{n}" }
    association :organization, :factory => :organization
    asset_subtype { AssetSubtype.first }
    purchase_cost { 2000.0 }
    # purchase_date and in_service_date are coupled by a validation
    # (in_service_date >= purchase_date); override both together.
    purchase_date { 1.year.ago.to_date }
    in_service_date { 1.year.ago.to_date }
    purchased_new { false }
    # NEW-6 workaround: PolicyAware#update_asset_state dereferences a value its own
    # rescue can leave nil. Same default as TTPLAT-3072's factories.
    policy_replacement_year { 2000 }

    # PolicyAware (after_save :check_policy_rule) needs the organization to have a
    # policy with rules for the asset's type and subtype. Orgs that already have a
    # policy (a spec that built its own) are left alone.
    before(:create) do |asset|
      org = asset.organization
      unless Policy.exists?(organization_id: org.id)
        policy = create(:policy, :organization => org)
        create(:policy_asset_type_rule, :policy => policy, :asset_type => asset.asset_subtype.asset_type)
        create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => asset.asset_subtype,
               :min_used_purchase_service_life_months => 120)
      end
    end
  end

end
