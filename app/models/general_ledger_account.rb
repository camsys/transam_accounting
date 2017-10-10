#------------------------------------------------------------------------------
#
# GeneralLedgerAccount
#
# Represents a general ledger account that exists in an external accounting
# system. This model is used to associate assets with accounting system accounts
# in an external business system and is not designed to replicate a general ledger
#
#------------------------------------------------------------------------------
class GeneralLedgerAccount < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Clean up any HABTM associations before the asset is destroyed
  #before_destroy { grants.clear }


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every ledger account belongs to an chart of accounts
  belongs_to :chart_of_account

  # Every GLA has an account type
  belongs_to :general_ledger_account_type
  belongs_to :general_ledger_account_subtype

  has_many :general_ledger_account_entries, :dependent => :destroy

  belongs_to :grant

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :chart_of_account,              :presence => true
  validates :general_ledger_account_type,   :presence => true
  validates :general_ledger_account_subtype,   :presence => true
  validates :name,                          :presence => true
  validates :account_number,                :presence => true

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :chart_of_account_id,
    :general_ledger_account_type_id,
    :general_ledger_account_subtype_id,
    :name,
    :account_number,
    :grant_id,
    :active,
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }

  scope :asset_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Asset Account')) }
  scope :liability_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Liability Account')) }
  scope :equity_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Equity Account')) }
  scope :revenue_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Revenue Account')) }
  scope :expense_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Expense Account')) }

  scope :fixed_asset_accounts, -> { where(:general_ledger_account_subtype => GeneralLedgerAccountSubtype.find_by(name: 'Fixed Asset Account')) }
  scope :grant_funding_accounts, -> { where(:general_ledger_account_subtype => GeneralLedgerAccountSubtype.find_by(name: 'Grant Funding Account')) }
  scope :accumulated_depreciation_accounts, -> { where(:general_ledger_account_subtype => GeneralLedgerAccountSubtype.find_by(name: 'Accumulated Depreciation Account')) }
  scope :depreciation_expense_accounts, -> { where(:general_ledger_account_subtype => GeneralLedgerAccountSubtype.find_by(name: 'Depreciation Expense Account')) }
  scope :disposal_accounts, -> { where(:general_ledger_account_subtype => GeneralLedgerAccountSubtype.find_by(name: 'Disposal Account')) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def grant_specific?
    grant.present?
  end

  def fixed_asset_account?
    general_ledger_account_subtype.name == 'Fixed Asset Account'
  end

  def to_s
    account_number
  end

  def subtotal
    general_ledger_account_entries.sum(:amount)
  end

  def asset_subtypes
    AssetSubtype.where(id: GeneralLedgerMapping.where('asset_account_id = ? OR depr_expense_account_id = ? OR accumulated_depr_account_id = ? OR gain_loss_account_id = ?', self, self, self, self).pluck(:asset_subtype_id))
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

    # Set resonable defaults for general ledger accounts
    def set_defaults
      self.general_ledger_account_type_id ||= self.general_ledger_account_subtype.try(:general_ledger_account_type_id)
      self.active = self.active.nil? ? true : self.active
    end

end
