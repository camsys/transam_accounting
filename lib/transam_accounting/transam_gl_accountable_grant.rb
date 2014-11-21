module TransamAccounting

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

    protected

  end
end
