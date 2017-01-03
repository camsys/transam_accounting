#------------------------------------------------------------------------------
#
# GrantBudget
#
# Represents the join between a general ledge account and a grant
#
#------------------------------------------------------------------------------
class GrantBudget < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :general_ledger_account
  belongs_to :grant


  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :general_ledger_account,    :presence => true
  validates :grant,                     :presence => true
  validates :amount,                    :allow_nil => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :general_ledger_account_id,
    :grant_id,
    :amount
  ]

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
    "#{grant}: $#{amount}"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

end
