module TransamAccountingVendor
  #------------------------------------------------------------------------------
  #
  # Accountable
  #
  # Injects methods and associations for depreciating assets into an
  # Policy class
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    include FiscalYear

    #------------------------------------------------------------------------------
    # Callbacks
    #------------------------------------------------------------------------------

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    has_many  :expenditures

    # ----------------------------------------------------
    # Validations
    # ----------------------------------------------------

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  module ClassMethods

  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # return expenditures in the current fiscal year
  def expenditures_ytd
    # get end of last fiscal year
    last_fy_end = fiscal_year_end_date(Date.today - 1.year)

    expenditures.where("purchase_date > ?", last_fy_end)
  end

  protected

end
