#------------------------------------------------------------------------------
#
# GeneralLedgerAccount
#
# Represents a general ledge account that exists in an external accounting
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
  
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every ledger account belongs to an chart of accounts
  belongs_to :chart_of_account
  
  # Every GLA has an account type
  belongs_to :general_ledger_account_type

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
    :active
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  default_scope { where(:active => true) }

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
  
end
      
