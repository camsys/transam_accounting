#------------------------------------------------------------------------------
#
# AssetValueUpdateJob
#
# Updates an assets estimated value
#
#------------------------------------------------------------------------------
class AssetValueUpdateJob < AbstractAssetUpdateJob

  def execute_job(asset)
    if asset.current_depreciation_date == Date.today
      asset.update_book_value
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetValueUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
