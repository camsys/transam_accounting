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
  before_destroy { grants.clear }


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every ledger account belongs to an chart of accounts
  belongs_to :chart_of_account

  # Every GLA has an account type
  belongs_to :general_ledger_account_type

  # Every GLA has 0 or more grants. This is not a strictly HABTM relationship
  # but it allows us to relate GLAs to grants without modifying the grants table
  # which is in the transit engine
  has_many :grant_budgets

  # Allow the form to submit grant purchases
  accepts_nested_attributes_for :grant_budgets, :reject_if => :all_blank, :allow_destroy => true

  has_many :funding_sources, :source => :sourceable, :source_type => 'FundingSource', :through => :grant_budgets
  has_many :grants, :source => :sourceable, :source_type => 'Grant', :through => :grant_budgets

  # Each GLA has 0 or more expenditures
  has_many :expenditures

  # Every GLA has and belongs to many assets
  has_many :grant_purchases, :through => :grant_budgets
  has_many :assets, :through => :grant_purchases

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :chart_of_account,              :presence => true
  validates :general_ledger_account_type,   :presence => true
  validates :name,                          :presence => true, :length => {:maximum => 64}
  validates :account_number,                :presence => true, :length => {:maximum => 32}

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :chart_of_account_id,
    :general_ledger_account_type_id,
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

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

    # Set resonable defaults for general ledger accounts
    def set_defaults
      self.active = self.active.nil? ? true : self.active
    end

end
