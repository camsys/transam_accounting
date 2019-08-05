#------------------------------------------------------------------------------
#
# AssetDepreciationExpenseUpdateJob
#
#
#------------------------------------------------------------------------------
class AssetDepreciationExpenseUpdateJob < ActivityJob


  def run
    asset_klass = Rails.application.config.asset_base_class_name.constantize

    asset_klass.not_in_transfer.where.not(current_depreciation_date: Policy.first.current_depreciation_date).or(asset_klass.not_in_transfer.where(current_depreciation_date: nil)).each do |a|
      asset = asset_klass.get_typed_asset(a)
      asset.update_asset_book_value
    end
  end

  def clean_up
    super
    Rails.logger.debug "Completed AssetDepreciationExpenseUpdateJob at #{Time.now.to_s}"
  end

  def prepare
    super
    Rails.logger.debug "Executing AssetDepreciationExpenseUpdateJob at #{Time.now.to_s}"
  end

end