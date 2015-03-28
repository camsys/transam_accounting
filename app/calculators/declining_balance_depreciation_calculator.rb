#------------------------------------------------------------------------------
#
# DecliningBalanceDepreciationCalculator
#
#------------------------------------------------------------------------------
class DecliningBalanceDepreciationCalculator < DepreciationCalculator

  # Determines the estimated value for an asset.
  def calculate_on_date(asset,on_date)

    # depreciation time
    num_months = asset.expected_useful_life.nil? ? asset.policy_rule.max_service_life_months : asset.expected_useful_life

    # Depreciation months of the asset
    depreciation_months = asset.depreciation_months(on_date)

    Rails.logger.debug "Depreciation months = #{depreciation_months}, max service life months = #{num_months}"
    # calculate the annual depreciation rate. This is double the actual depreciation rate
    depreciation_rate = (1 / num_months.to_f) * 2
    rv = asset.salvage_value
    v  = purchase_cost(asset)
    Rails.logger.debug "purchase cost = #{v}, residual value = #{rv} depreciation_rate = #{depreciation_rate}"

    if depreciation_months < 1
      return v
    end

    # calculate the value of the asset at the end of each year
    (1..depreciation_months).each do |month|
      v -= (v * depreciation_rate)
      #Rails.logger.debug "month = #{month}, value = #{v}"
      # if the value drops below the residual value then the depreciation stops
      break if v < rv
    end
    # return the max of the residual value and the depreciated value
    [v, rv].max.to_i
  end

end
