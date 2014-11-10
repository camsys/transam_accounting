#------------------------------------------------------------------------------
#
# ChartOfAccount
#
# Represents a chart of accounts for an organization. Each org can have at most
# one chart of accounts which contains a list of the general ledger accounts for
# that organization.
#
#------------------------------------------------------------------------------
class ChartOfAccount < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every chart of accounts belongs to an organization
  belongs_to :organization

  # Every Chart of Accounts has a set of General Ledger Accounts
  has_many    :general_ledger_accounts, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :organization,      :presence => true


  # List of allowable form param hash keys
  FORM_PARAMS = [
    :organization_id,
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

  def name
    "Chart of Accounts"
  end
  def to_s
    name
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

    # Set resonable defaults for chart of accounts
    def set_defaults
      self.active ||= true
    end


end
