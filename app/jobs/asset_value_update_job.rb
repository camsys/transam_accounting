#------------------------------------------------------------------------------
#
# AssetValueUpdateJob
#
# Updates an assets estimated value
#
#------------------------------------------------------------------------------
class AssetValueUpdateJob < AbstractAssetUpdateJob

  def execute_job(asset)
    asset.update_book_value
  end

  def prepare
    Rails.logger.debug "Executing AssetValueUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
