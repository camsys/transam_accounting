# Do not configure Rail and Locomotive assets
Rails.application.config.transam_transit_rail = false

# Defines services to use
Rails.application.config.new_user_service = "NewUserService"
Rails.application.config.policy_analyzer = "TransitPolicyAnalyzer"

# Base class name is to determine base asset class. Seed class is used to determine seed that gets typed (or very specific) asset class.
Rails.application.config.asset_base_class_name = 'TransamAsset'
Rails.application.config.asset_seed_class_name = 'FtaAssetClass'