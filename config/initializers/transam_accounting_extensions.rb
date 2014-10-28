# Technique caged from http://stackoverflow.com/questions/4460800/how-to-monkey-patch-code-that-gets-auto-loaded-in-rails
Rails.configuration.to_prepare do
  Asset.class_eval do
    include TransamAccounting::TransamDepreciable
  end
  Organization.class_eval do
    include TransamAccounting::TransamAccountable
  end
  Policy.class_eval do
    include TransamAccounting::TransamAccountingPolicy
  end
end