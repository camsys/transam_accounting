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

  belongs_to :grant

  has_many :general_ledger_account_entries, :dependent => :destroy

  # Every GLA has 0 or more grants. This is not a strictly HABTM relationship
  # but it allows us to relate GLAs to grants without modifying the grants table
  # which is in the transit engine
  has_many :grant_budgets, :dependent => :destroy, :inverse_of => :general_ledger_account

  # Allow the form to submit grant purchases
  accepts_nested_attributes_for :grant_budgets, :reject_if => :all_blank, :allow_destroy => true

  has_many :grants, :through => :grant_budgets

  # Every GLA has and belongs to many assets
  has_many :assets

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :chart_of_account,              :presence => true
  validates :general_ledger_account_type,   :presence => true
  validates :general_ledger_account_subtype,   :presence => true
  validates :name,                          :presence => true, :length => {:maximum => 64}
  validates :account_number,                :presence => true, :length => {:maximum => 32}

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :chart_of_account_id,
    :general_ledger_account_type_id,
    :general_ledger_account_subtype_id,
    :name,
    :account_number,
    :active,
    :grant_budgets_attributes => [GrantBudget.allowable_params]
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }
  scope :fixed_asset_accounts, -> { where(:general_ledger_account_subtype => GeneralLedgerAccountSubtype.find_by(name: 'Fixed Asset Account')) }
  scope :asset_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Asset Account')) }
  scope :liability_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Liability Account')) }
  scope :equity_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Equity Account')) }
  scope :revenue_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Revenue Account')) }
  scope :expense_accounts, -> { where(:general_ledger_account_type => GeneralLedgerAccountType.find_by(name: 'Expense Account')) }

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

  def to_s
    account_number
  end

  def subtotal
    general_ledger_account_entries.sum(:amount)
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
