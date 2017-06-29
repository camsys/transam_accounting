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
    # Callbacks
    # ----------------------------------------------------

    after_create :set_general_ledger_accounts

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    belongs_to :general_ledger_account

    has_and_belongs_to_many :general_ledger_accounts, :foreign_key => :asset_id

    has_and_belongs_to_many :expenditures, :foreign_key => :asset_id

    # each asset was purchased using one or more grants
    has_many    :grant_purchases,  :foreign_key => :asset_id, :dependent => :destroy, :inverse_of => :asset

    # Allow the form to submit grant purchases
    accepts_nested_attributes_for :grant_purchases, :reject_if => :all_blank, :allow_destroy => true

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
    def self.allowable_params
      [
          :general_ledger_account_id,
          :grant_purchases_attributes => [GrantPurchase.allowable_params]
      ]
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  protected

  def set_general_ledger_accounts
    # ----------------------------------------------------------------------------------- #
    # Possible GLAs an asset can be associated with:
    # -- fixed asset account (main association: general_ledger_account_id)
    # -- grant funding
    # -- accumulated depr
    # -- depreciation expensep

    # -- gain/loss on disposal
    # -- cash
    # ----------------------------------------------------------------------------------- #

    # fixed asset account
    general_ledger_accounts << general_ledger_account

    # grant funding
    grant_purchases.each do |grant_purchase|
      gla = organization.general_ledger_accounts.find_by(account_number: "#{general_ledger_account.account_number}-#{grant_purchase.sourceable}")
      general_ledger_accounts << gla

      # add GLA entries
      amount = purchase_cost * grant_purchase.pcnt_purchase_cost / 100.0
      general_ledger_account.general_ledger_account_entries.create(description: "#{organization}: #{self.to_s}", amount: amount)
      gla.general_ledger_account_entries.create(description: "#{organization}: #{self.to_s}", amount: amount)

    end







  end

end
