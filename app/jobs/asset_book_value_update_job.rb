#------------------------------------------------------------------------------
#
# AssetBookValueUpdateJob
#
#
#------------------------------------------------------------------------------
class AssetBookValueUpdateJob < AbstractAssetUpdateJob
  
  def requires_sogr_update?
    false
  end  
  
  def execute_job(asset)       
    asset.update_book_value
  end

  def prepare
    Rails.logger.debug "Executing AssetBookValueUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end
 
end