#------------------------------------------------------------------------------
#
# StraightLineDepreciationCalculator
#
#------------------------------------------------------------------------------
class StraightLineDepreciationCalculator < DepreciationCalculator

  # Determines the estimated value for an asset on the current date.
  def calculate(asset, on_date=nil)

    # depreciation time
    num_years = asset.policy_rule.max_service_life_years

    # calcuate the depreciation
    annual_depreciation = basis(asset) / num_years.to_f

    # Age of the asset
    if on_date.nil?
      age = asset.age(asset.current_depreciation_date)
    else
      age = asset.age(on_date)
    end

    depreciated_value = purchase_cost(asset) - (annual_depreciation * age)
    Rails.logger.debug "num_years = #{num_years} annual_depreciation = #{annual_depreciation} purchase_cost = #{purchase_cost(asset)} basis = #{basis(asset)} age = #{age} depreciated_value = #{depreciated_value}"
    # return the max of the residual value and the depreciated value
    [depreciated_value, residual_value(asset)].max
  end

end
