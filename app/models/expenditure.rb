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

  before_save :create_depreciation_entry

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every expenditure must be associated with a GL account
  belongs_to :general_ledger_account

  belongs_to :grant

  # Every expenditure must be associated with an expense type
  belongs_to :expense_type

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
      :expense_date,
      :description,
      :amount,
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
  def create_depreciation_entry
    gl_mapping = GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: asset.organization_id).id, asset_subtype_id: asset.asset_subtype_id)
    if gl_mapping.present? # check whether this app records GLAs at all
      if event_date - 1.year < asset.depreciation_start_date
        depr_amount = asset.depreciation_entries.find_by(description: 'Initial Value', event_date: asset.depreciation_start_date).book_value - book_value
      else
        depr_amount = asset.depreciation_entries.find_by(description: 'Annual Adjustment', event_date: event_date - 1.year).book_value - book_value
      end
      gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "Manual Adjustment - Accumulated Depr #{asset.asset_path}", amount: -depr_amount)

      gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "Manual Adjustment - Depr Expense #{asset.asset_path}", amount: depr_amount)

    end

    self.asset.depreciation_entries.create!(description: self.comments, book_value: self.book_value, event_date: self.event_date)
  end


  # Set resonable defaults for a suppoert facility
  def set_defaults
    self.amount ||= 0
    self.pcnt_from_grant ||= 0
    self.expense_date ||= Date.today
  end

end