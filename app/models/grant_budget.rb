#------------------------------------------------------------------------------
#
# GrantBudget
#
# Represents the join between a general ledge account and a grant
#
#------------------------------------------------------------------------------
class GrantBudget < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults
  after_save                        :update_general_ledger_accounts
  before_destroy                    :delete_general_ledger_accounts

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to  :grant
  belongs_to  :general_ledger_account

  # Has many grant purchases
  has_many :grant_purchases, :as => :sourceable, :dependent => :destroy
  has_many :assets, :through => :grant_purchases


  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates_presence_of :grant
  validates_presence_of :general_ledger_account
  validates :amount,                    :allow_nil => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :id,
    :general_ledger_account_id,
    :grant_id,
    :amount,
    :_destroy
  ]

  scope :active, -> { where(:active => true) }

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

  def to_s
    name
  end
  
  def name
    "#{grant} #{general_ledger_account}"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def update_general_ledger_accounts
    # for each grant budget, create/update funding GLA
    grant_funding_gla = GeneralLedgerAccount.find_or_create_by(chart_of_account_id: general_ledger_account.chart_of_account_id, general_ledger_account_type_id: GeneralLedgerAccountType.find_by(name: 'Asset Account').id, general_ledger_account_subtype_id: GeneralLedgerAccountSubtype.find_by(name: 'Grant Funding Account').id, account_number: "#{general_ledger_account.account_number}-#{grant}", name: "#{general_ledger_account.name} #{grant} Funding", grant_id: grant.id)
    if grant_funding_gla.subtotal != amount
      grant_funding_gla_entry = grant_funding_gla.general_ledger_account_entries.find_or_create_by(description: 'Grant Funding', sourceable: grant)
      grant_funding_gla_entry.update!(amount: amount - grant_funding_gla.subtotal)
    end
  end

  def delete_general_ledger_accounts
    grant_funding_gla = GeneralLedgerAccount.find_by(chart_of_account_id: general_ledger_account.chart_of_account_id, general_ledger_account_type_id: GeneralLedgerAccountType.find_by(name: 'Asset Account').id, general_ledger_account_subtype_id: GeneralLedgerAccountSubtype.find_by(name: 'Grant Funding Account').id, account_number: "#{general_ledger_account.account_number}-#{grant}", name: "#{general_ledger_account.name} #{grant} Funding", grant_id: grant.id)
    grant_funding_gla.general_ledger_account_entries.find_by(sourceable: grant).destroy
    grant_funding_gla.destroy if grant_funding_gla.general_ledger_account_entries.count == 0
  end

  # Set resonable defaults for a new grant
  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end

end
