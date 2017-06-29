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
  validates :amount,                    :allow_nil => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

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

  # Set resonable defaults for a new grant
  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end

end
