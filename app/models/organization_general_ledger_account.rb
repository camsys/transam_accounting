class OrganizationGeneralLedgerAccount < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to :general_ledger_account_type
  belongs_to :general_ledger_account_subtype

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :general_ledger_account_type,              :presence => true
  validates :general_ledger_account_subtype,           :presence => true
  validates :name,                                     :presence => true
  validates :account_number,                           :presence => true

  scope :active, -> { where(active: true) }

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def to_s
    name
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for general ledger account entries
  def set_defaults
    self.grant_budget_specific = self.grant_budget_specific.nil? ? true : self.grant_budget_specific
    self.active = self.active.nil? ? true : self.active
  end
end
