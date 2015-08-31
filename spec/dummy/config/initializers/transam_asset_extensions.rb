# Add asset plugins for this app
Rails.configuration.to_prepare do
  Asset.class_eval do
    # Accounting
    include TransamDepreciable
  end
end
