module TransamGlAccountableGrant
  #------------------------------------------------------------------------------
  #
  # Accountable
  #
  # Injects methods and associations for managing general ledger accounts for a grant
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    has_many :grant_budgets
    has_many :general_ledger_accounts, :through => :grant_budgets

    has_many :expenditures

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

  def capex_spending
    total_capex = 0

    expenditures.each do |exp|
      spending = exp.amount.to_f * exp.pct_from_grant / 100
      total_capex += spending
    end

    total_capex
  end

  protected

end
