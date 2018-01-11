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

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    # each asset was purchased using one or more grants
    has_many    :grant_purchases,  :foreign_key => :asset_id, :dependent => :destroy, :inverse_of => :asset

    # Allow the form to submit grant purchases
    accepts_nested_attributes_for :grant_purchases, :reject_if => :all_blank, :allow_destroy => true

    # Override core asset model so that expenditures don't affect parent-child relationships and rollups
    has_many    :dependents, -> { where.not(:asset_type_id => AssetType.find_by(class_name: 'Expenditure').try(:id)) },  :class_name => 'Asset', :foreign_key => :parent_id, :dependent => :nullify

    has_and_belongs_to_many    :expenditures, :foreign_key => :asset_id

    has_many :general_ledger_account_entries, :foreign_key => :asset_id

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

  def asset_path
    url = Rails.application.routes.url_helpers.inventory_path(self)
    "<a href='#{url}'>#{self.asset_tag}</a>"
  end

  def general_ledger_mapping
    if ChartOfAccount.find_by(organization_id: self.organization_id)
      GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: self.organization_id).id, asset_subtype_id: self.asset_subtype_id)
    end
  end

  protected

end
