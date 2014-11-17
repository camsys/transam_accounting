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
  validates :amount,                    :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

end
