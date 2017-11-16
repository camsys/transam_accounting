
class BookValueUpdateEvent < AssetEvent
      
  # Callbacks
  after_initialize :set_defaults

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

  def can_update?
     false # set to false so it doesnt show up in the asset detail page action menu and existing events cannot be updated
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
  end

  def create_depreciation_entry
    depr_amount = asset.depreciation_entries.where('event_date <= ?',self.event_date).sum(:book_value) - book_value

    asset.depreciation_entries.create!(description: "Manual Adjustment: #{self.comments}", book_value: -depr_amount, event_date: self.event_date)
    asset.update_columns(current_depreciation_date: self.event_date)

    gl_mapping = GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: asset.organization_id).id, asset_subtype_id: asset.asset_subtype_id)
    if gl_mapping.present? # check whether this app records GLAs at all
      gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "Manual Adjustment - Accumulated Depreciation: #{asset.asset_path}", amount: -depr_amount, asset: asset)

      gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "Manual Adjustment - Deprectiation Expense: #{asset.asset_path}", amount: depr_amount, asset: asset)
    end

    # destroy any manual adjustments past the depr start
    asset.depreciation_entries.manual_adjustments.where('event_date > ?',self.event_date).each do |depr_entry|
      if gl_mapping.present?
        gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Manual Adjustment - Accumulated Depreciation: #{asset.asset_path}", amount: -depr_entry.book_value, asset: asset)

        gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Manual Adjustment - Depreciation Expense: #{asset.asset_path}", amount: depr_entry.book_value, asset: asset)
      end

      depr_entry.destroy!
    end

    asset.depreciation_entries.depreciation_expenses.where('event_date > ?',self.event_date).each do |depr_entry|
      if gl_mapping.present?
        gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Accumulated Depreciation: #{asset.asset_path}", amount: -depr_entry.book_value, asset: asset)

        gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Deprectiation Expense: #{asset.asset_path}", amount: depr_entry.book_value, asset: asset)
      end

      depr_entry.destroy!
    end
  end
  
end
