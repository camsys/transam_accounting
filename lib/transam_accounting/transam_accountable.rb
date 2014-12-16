module TransamAccounting

  module TransamAccountable
    #------------------------------------------------------------------------------
    #
    # Accountable
    #
    # Injects methods and associations for managing depreciable assets into an
    # Organization class
    #
    # Model
    #
    #------------------------------------------------------------------------------
    extend ActiveSupport::Concern

    included do

      # ----------------------------------------------------
      # Associations
      # ----------------------------------------------------

      # Each org can have 0 or more grants
      has_many  :grants

      # Each org can have 0 or more expenditures
      has_many  :expeditures

      # Each org can have 0 or 1 chart of accounts
      has_one   :chart_of_account

      # Each org can have 0 or more general ledger accounts if they have a chart of accounts
      has_many  :general_ledger_accounts, :through => :chart_of_account

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

    # Utility method for returning the chart of accounts
    def chart_of_accounts
      chart_of_account
    end

    protected

  end
end
