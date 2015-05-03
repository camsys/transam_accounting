#------------------------------------------------------------------------------
#
# Expenditure
#
# Represents an expenditure in TransAM. Expenditures are tracked against
# assets, general ledger accounts, and optionally grants.
#
# An expenditure can optionally be associated more than one asset, for example,
# an inspector could inspect several busses and provide a single invoice.
#
#------------------------------------------------------------------------------
class Expenditure < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Clean up any HABTM associations before the expenditure is destroyed
  before_destroy { assets.clear }

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every expenditure is owned by an organization
  belongs_to :organization

  # Every expenditure must be associated with a GL account
  belongs_to :general_ledger_account

  # Every expenditure can optionally be associated with a Grant
  belongs_to :grant

  # Every expenditure must be associated with an expense type
  belongs_to :expense_type

  # each was puchased from a vendor
  belongs_to :vendor

  # Every expenditure can be associated with one or more assets
  has_and_belongs_to_many :assets

  # Has 0 or more documents. Using a polymorphic association. These will be removed if the project is removed
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  # Has 0 or more comments. Using a polymorphic association, These will be removed if the project is removed
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  #validates :general_ledger_account,    :presence => true
  validates :organization,              :presence => true
  #validates :grant,                     :presence => true
  validates :expense_type,              :presence => true
  validates :expense_date,              :presence => true
  validates :description,               :presence => true
  validates :amount,                    :allow_nil => true, :numericality => {:only_integer => :true}
  validates :pcnt_from_grant,           :allow_nil => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :general_ledger_account_id,
    :grant_id,
    :expense_type_id,
    :vendor_id,
    :expense_date,
    :description,
    :amount,
    :pcnt_from_grant,
    :asset_ids => []
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :general_ledger_account,
    :grant,
    :expense_type,
    :name,
    :description
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
    description
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a suppoert facility
  def set_defaults
    self.amount ||= 0
    self.pcnt_from_grant ||= 0
    self.expense_date ||= Date.today
  end

end
