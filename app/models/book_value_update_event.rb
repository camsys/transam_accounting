
class BookValueUpdateEvent < AssetEvent

  include TransamFormatHelper
      
  # Callbacks
  after_initialize :set_defaults

  before_save      :set_event_date_for_depr_interval

  after_create     :create_depreciation_entry


  validates :book_value,   :presence => true
  validates :comments,     :presence => true
      
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_event_type_id => AssetEventType.find_by_class_name(self.name).id).order(:event_date, :created_at) }
    
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :book_value
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #returns the asset event type for this type of event
  def self.asset_event_type
    AssetEventType.find_by_class_name(self.name)
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # This must be overriden otherwise a stack error will occur  
  def get_update
    "Book value: #{self.book_value}."
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
  end

  def set_event_date_for_depr_interval
    self.event_date = asset.policy_analyzer.get_depreciation_date(self.event_date)
  end

  def create_depreciation_entry
    gl_mapping = GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: asset.organization_id).id, asset_subtype_id: asset.asset_subtype_id)
    if gl_mapping.present? # check whether this app records GLAs at all
      depr_amount = asset.book_value || asset.depreciation_purchase_cost - book_value

      gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "Manual Adjustment - Accumulated Depr #{asset.asset_path}", amount: -depr_amount)

      gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "Manual Adjustment - Depr Expense #{asset.asset_path}", amount: depr_amount)
    end

    asset.depreciation_entries.create!(description: "Manual Adjustment - #{self.comments}", book_value: self.book_value, event_date: self.event_date)
    asset.update(book_value: self.book_value)
  end
  
end
