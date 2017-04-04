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

    has_and_belongs_to_many :general_ledger_accounts, :foreign_key => :asset_id
    has_and_belongs_to_many :expenditures, :foreign_key => :asset_id

    # each asset was purchased using one or more grants
    has_many    :grant_purchases,  :foreign_key => :asset_id, :dependent => :destroy, :inverse_of => :asset

    # Allow the form to submit grant purchases
    accepts_nested_attributes_for :grant_purchases, :reject_if => lambda{|a| a[:sourceable_id].blank?}, :allow_destroy => true

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

end
