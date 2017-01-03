Rails.configuration.to_prepare do

  Asset.class_eval do
    include TransamGlAccountableAsset
    include TransamDepreciable
  end

  AssetsController.class_eval do
    include TransamAccountingAssetsController
  end

  Organization.class_eval do
    include TransamAccountable
  end

  Policy.class_eval do
    include TransamAccountingPolicy
  end

  Vendor.class_eval do
    include TransamAccountingVendor
  end

  Grant.class_eval do
    include TransamGlAccountableGrant
  end
end
