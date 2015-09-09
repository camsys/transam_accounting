# Do not configure Rail and Locomotive assets
Rails.application.config.transam_transit_rail = false

# Defines services to use
Rails.application.config.new_user_service = "NewUserService"
Rails.application.config.policy_analyzer = "TransitPolicyAnalyzer"
