#------------------------------------------------------------------------------
#
# Base class for calculating asset depreciation
#
#------------------------------------------------------------------------------
class DepreciationCalculator < Calculator

  # ----------------------------
  # Depreciation Calculator Methods
  #
  # calculate - returns current (depreciated) value of asset
  #
  # calculate_on_date - returns depreciated value of asset on a specific date
  #
  # purchase_cost - purchase cost of asset
  #
  # total_depreciation - returns the total depreciation amount
  #
  # salvage_value - returns the min depreciated value of the asset
  # If set by user, returns user input. Otherwise, calculated based on pcnt_residual_value
  #
  # book_value_start - returns the book value at the beginning of the fiscal year
  #
  # book_value_end - returns the book value at the end of the fiscal year
  #
  # depreciated_expense - returns the depreciation for a fiscal year
  # returns book_value_start - book_value_end
  #
  # accumulated_depreciation - returns the accumulated depreciation up to the fiscal year
  # returns purchase_cost - book_value_end
  #
  # -----------------------------

  def calculate(asset)
    calculate_on_date(asset, asset.policy.current_depreciation_date)
  end

  def purchase_cost(asset)
    asset.purchase_cost
  end

  def total_depreciation(asset)
    # Get the total_depreciation for the depreciation as the purchase price minus the residual value at
    # the end of the asset's useful life
    [purchase_cost(asset) - asset.salvage_value, 0].max
  end

end
