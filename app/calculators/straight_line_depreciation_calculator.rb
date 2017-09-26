#------------------------------------------------------------------------------
#
# StraightLineDepreciationCalculator
#
#------------------------------------------------------------------------------
class StraightLineDepreciationCalculator < DepreciationCalculator

  # Determines the estimated value for an asset on the current date.
  def calculate_on_date(asset, on_date)

    # depreciation time
    num_months = asset.expected_useful_life.nil? ? asset.policy_analyzer.get_min_service_life_months : asset.expected_useful_life

    # calcuate the depreciation
    if num_months > 0
      monthly_depreciation = total_depreciation(asset) / num_months.to_f
    end

    # Depreciation months of the asset
    depreciation_months = asset.depreciation_months(on_date, asset.depreciation_entries.where('event_date <= ?').last.event_date)

    last_book_value = asset.depreciation_entries.where('event_date <= ?').last.book_value

    if depreciation_months < 1 || monthly_depreciation.nil? || asset.depreciation_entries.where('event_date > ?', on_date).count > 0
      return last_book_value
    end

    depreciated_value = last_book_value - (monthly_depreciation * depreciation_months)
    Rails.logger.debug "num_months = #{num_months} monthly_depreciation = #{monthly_depreciation} purchase_cost = #{purchase_cost(asset)} total_depreciation = #{total_depreciation(asset)} depreciation_months = #{depreciation_months} depreciated_value = #{depreciated_value}"
    # return the max of the residual value and the depreciated value
    [depreciated_value, asset.salvage_value].max

  end

end
