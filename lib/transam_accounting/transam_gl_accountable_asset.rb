module TransamAccounting

  module TransamGlAccountableAsset
    #------------------------------------------------------------------------------
    #
    # Accountable
    #
    # Injects methods and associations for managing general ledger accounts for an asset
    #
    # Model
    #
    #------------------------------------------------------------------------------
    extend ActiveSupport::Concern

    included do

      # ----------------------------------------------------
      # Associations
      # ----------------------------------------------------

      has_and_belongs_to_many :general_ledger_accounts
      has_and_belongs_to_many :expenditures

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
