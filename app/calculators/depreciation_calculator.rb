#------------------------------------------------------------------------------
#
# Base class for calculating asset depreciation
#
#------------------------------------------------------------------------------
class DepreciationCalculator < Calculator

  def total_depreciation(asset)
    # Get the total_depreciation for the depreciation as the purchase price minus the residual value at
    # the end of the asset's useful life
    purchase_cost(asset) - salvage_value(asset)
  end

  def salvage_value(asset)
    asset.salvage_value.nil? ? purchase_cost(asset) * (asset.policy_rule.pcnt_residual_value / 100.0) : asset.salvage_value
  end

  def purchase_cost(asset)
    asset.purchase_cost
  end

  def depreciated_value(asset, on_date=nil)
    purchase_cost(asset) - calculate_on_date(asset, on_date)
  end

  # the amount of depreciation for the current accounting period
  def current_ytd_depreciation(asset)
    prev_accounting_period = Date.new(asset.current_depreciation_date.year - 1, asset.depreciation_start_date.month, asset.depreciation_start_date.day)

    calculate(asset) - calculate_on_date(asset,prev_accounting_period)
  end

  # the amount of depreciation for the previous accounting period
  def beginning_ytd_depreciation(asset)
    prev_accounting_period = Date.new(asset.current_depreciation_date.year - 1, asset.depreciation_start_date.month, asset.depreciation_start_date.day)

    calculate_on_date(asset,prev_accounting_period) - calculate_on_date(asset,prev_accounting_period - 1.years)
  end

  # the amount of accumulated depreciation for the previous accounting period
  def beginning_accumulated_depreciation(asset)
    prev_accounting_period = Date.new(asset.current_depreciation_date.year - 1, asset.depreciation_start_date.month, asset.depreciation_start_date.day)

    calculate_on_date(asset,prev_accounting_period)
  end

end
