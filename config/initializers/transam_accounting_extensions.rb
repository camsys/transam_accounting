# Technique caged from http://stackoverflow.com/questions/4460800/how-to-monkey-patch-code-that-gets-auto-loaded-in-rails
# See http://guides.rubyonrails.org/configuring.html#initialization-events for
# details on Initialization Events
###############################################################################
#
# Hook into the Rails initialization sequence.  to_prepare hook will fire once
# on-boot in prod or test, but before each request in development
# NOTE: All classes listed for class_eval here will be evaluated, including
#   their modules, but the event fires before DB initialization, so any DB
#   calls WILL FAIL
#
###############################################################################
Rails.configuration.to_prepare do
  Asset.class_eval do
    include TransamAccounting::TransamDepreciable
    include TransamAccounting::TransamGlAccountableAsset
  end
  AssetsController.class_eval do
    include TransamAccounting::TransamAccountingAssetsController
  end
  Grant.class_eval do
    include TransamAccounting::TransamGlAccountableGrant
  end
  Organization.class_eval do
    include TransamAccounting::TransamAccountable
  end
  Policy.class_eval do
    include TransamAccounting::TransamAccountingPolicy
  end
  Vendor.class_eval do
    include TransamAccounting::TransamAccountingVendor
  end
end
