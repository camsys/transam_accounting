#------------------------------------------------------------------------------
#
# StraightLineDepreciationCalculator
#
#------------------------------------------------------------------------------
class StraightLineDepreciationCalculator < DepreciationCalculator

  # Determines the estimated value for an asset on the current date.
  def calculate_on_date(asset, on_date)

    # depreciation time
    num_months_initial = asset.depreciation_useful_life.nil? ? asset.policy_analyzer.get_min_service_life_months : asset.depreciation_useful_life
    last_depr_date = on_date - (asset.policy_analyzer.get_depreciation_interval_type.months).months
    num_months_used = (last_depr_date.year * 12 + last_depr_date.month) - (asset.depreciation_start_date.year * 12 + asset.depreciation_start_date.month)
    num_months_extended = asset.rehabilitation_updates.sum(:extended_useful_life_months)
    num_months_unused = num_months_initial-num_months_used+num_months_extended

    # calcuate the depreciation
    if num_months_unused > 0
      monthly_depreciation = asset.book_value / num_months_unused.to_f
    end

    # Depreciation months of the asset
    depreciation_months = asset.depreciation_months(on_date, asset.depreciation_entries.depreciation_expenses.where('event_date <= ?', on_date).last.try(:event_date) || asset.depreciation_entries.find_by(description: 'Purchase').event_date)

    if depreciation_months < 1 || monthly_depreciation.nil? || asset.depreciation_entries.where('event_date > ?', on_date).count > 0
      return asset.book_value
    end

    depreciated_value = asset.book_value - (monthly_depreciation * depreciation_months)
    Rails.logger.debug "num_months = #{num_months_unused} monthly_depreciation = #{monthly_depreciation} purchase_cost = #{purchase_cost(asset)} total_depreciation = #{total_depreciation(asset)} depreciation_months = #{depreciation_months} depreciated_value = #{depreciated_value}"
    # return the max of the residual value and the depreciated value
    [depreciated_value, asset.salvage_value].max

  end

end
