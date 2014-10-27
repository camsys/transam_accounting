#------------------------------------------------------------------------------
#
# Base class for calculating asset depreciation
#
#------------------------------------------------------------------------------
class DepreciationCalculator < Calculator

  def basis(asset)
    # Get the basis for the depreciation as the purchase price minus the residual value at
    # the end of the asset's useful life
    purchase_cost(asset) - residual_value(asset)
  end

  def residual_value(asset)
    purchase_cost(asset) * (asset.policy_rule.pcnt_residual_value / 100.0)
  end

  def purchase_cost(asset)
    asset.purchase_cost
  end

  def depreciated_value(asset, on_date=nil)
    purchase_cost(asset) - calculate(asset, on_date)
  end

  # the amount of depreciation for the current accounting period
  def current_ytd_depreciation(asset)
    prev_accounting_period = Date.new(asset.current_depreciation_date.year - 1, asset.depreciation_start_date.month, asset.depreciation_start_date.day)

    calculate(asset) - calculate(asset,prev_accounting_period)
  end

  # the amount of depreciation for the previous accounting period
  def beginning_ytd_depreciation(asset)
    prev_accounting_period = Date.new(asset.current_depreciation_date.year - 1, asset.depreciation_start_date.month, asset.depreciation_start_date.day)

    calculate(asset,prev_accounting_period) - calculate(asset,prev_accounting_period - 1.years)
  end

  # the amount of accumulated depreciation for the previous accounting period
  def beginning_accumulated_depreciation(asset)
    prev_accounting_period = Date.new(asset.current_depreciation_date.year - 1, asset.depreciation_start_date.month, asset.depreciation_start_date.day)

    calculate(asset,prev_accounting_period)
  end

end
