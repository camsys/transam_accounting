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

  def purchase_cost(asset)
    asset.purchase_cost
  end

  def total_depreciation(asset)
    # Get the total_depreciation for the depreciation as the purchase price minus the residual value at
    # the end of the asset's useful life
    purchase_cost(asset) - salvage_value(asset)
  end

  def salvage_value(asset)
    asset.salvage_value.nil? ? purchase_cost(asset) * (asset.policy_rule.pcnt_residual_value / 100.0) : asset.salvage_value
  end

  def book_value_start(asset, fiscal_year_date)
    calculate_on_date(asset, [asset.depreciation_start_date,fiscal_year_date - 1.year].max)
  end

  def book_value_end(asset, fiscal_year_date)
    calculate_on_date(asset, fiscal_year_date)
  end

  def depreciated_expense(asset, fiscal_year_date)
    book_value_start(asset, fiscal_year_date) - book_value_end(asset, fiscal_year_date)
  end

  def accumulated_depreciation(asset, fiscal_year_date)
    purchase_cost(asset) - book_value_end(asset, fiscal_year_date)
  end

end
