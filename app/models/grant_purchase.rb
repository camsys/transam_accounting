#------------------------------------------------------------------------------
#
# GrantPurchase
#
# Tracks asset purchases against specific funding. Each purchase tracks the percentage
# of the asset cost against the funding.
#
#------------------------------------------------------------------------------
class GrantPurchase < ActiveRecord::Base

  SOURCEABLE_TYPE = Rails.application.config.asset_purchase_source

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  after_save        :update_general_ledger_accounts, :if => Proc.new{ self.sourceable_type == 'Grant' }
  before_destroy    :delete_general_ledger_accounts, :if => Proc.new{ self.sourceable_type == 'Grant' }

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every grant purchase is associated with an asset and some form of funding (sourceable)
  belongs_to  :sourceable, :polymorphic => true
  belongs_to  :asset

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates_presence_of :sourceable
  validates_presence_of :asset
  validates :pcnt_purchase_cost,  :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :id,
    :asset_id,
    :sourceable_type,
    :sourceable_id,
    :pcnt_purchase_cost,
    :_destroy
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.sourceable_type
    SOURCEABLE_TYPE
  end

  def self.sources(params=nil)
    if params
      # check whether params are valid
      params = params.stringify_keys

      # override special case if sourceable type is GrantBudget
      clean_params = params.slice(*(params.keys & SOURCEABLE_TYPE.constantize.column_names))
      SOURCEABLE_TYPE.constantize.where(clean_params)

    else
      SOURCEABLE_TYPE.constantize.active
    end
  end

  def self.label
    if SOURCEABLE_TYPE == 'FundingSource'
      'Funding Program'
    else
      SOURCEABLE_TYPE.constantize.model_name.human.titleize
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Virtual attribute for setting a grant by its ID so we can patch around
  # a limitation in the accepts_nested_attributes_for
  def sourceable_id=(val)
    self.sourceable = SOURCEABLE_TYPE.constantize.find(val)
  end
  def sourceable_id
    sourceable.try(:id)
  end

  def to_s
    name
  end

  def name
    "#{sourceable}: #{pcnt_purchase_cost}%"
  end

  def sourceable_path
    "#{sourceable_type.underscore}_path(id: '#{sourceable.object_key}')"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults

    self.pcnt_purchase_cost ||= 0

  end

  def update_general_ledger_accounts
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
    asset_gla = asset.general_ledger_account
    asset.general_ledger_accounts << asset_gla

    grant_gla = asset.organization.general_ledger_accounts.find_by(grant: sourceable)
    if grant_gla.nil?
      grant_gla = GeneralLedgerAccount.create!(chart_of_account_id: asset_gla.chart_of_account_id, general_ledger_account_type_id: GeneralLedgerAccountType.find_by(name: 'Asset Account').id, general_ledger_account_subtype_id: GeneralLedgerAccountSubtype.find_by(name: 'Grant Funding Account').id, account_number: "#{asset_gla.account_number}-#{grant}", name: "#{asset_gla.name} #{grant} Funding", grant_id: sourceable.id)
    end
    asset.general_ledger_accounts << grant_gla

    # add GLA entries
    amount = asset.purchase_cost * pcnt_purchase_cost / 100.0

    asset_gla_entry = asset_gla.general_ledger_account_entries.find_or_create_by(sourceable_type: 'Asset', sourceable_id: asset.id)
    asset_gla_entry.update!(description: "#{asset.organization}: #{asset.to_s}", amount: amount)

    grant_gla_entry = grant_gla.general_ledger_account_entries.find_or_create_by(sourceable_type: 'Asset', sourceable_id: asset.id)
    grant_gla_entry.update!(description: "#{asset.organization}: #{asset.to_s}", amount: -amount)
  end

  def delete_general_ledger_accounts
    grant_gla = asset.organization.general_ledger_accounts.find_by(grant: sourceable)
    grant_gla.general_ledger_account_entries.find_by(sourceable_type: 'Asset', sourceable_id: asset.id).destroy
    asset.general_ledger_accounts.delete(grant_gla)
  end

end
