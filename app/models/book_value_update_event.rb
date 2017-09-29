
class BookValueUpdateEvent < AssetEvent

  include TransamFormatHelper
      
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
    "Book value: #{format_as_currency(self.book_value)}."
  end
  
  protected

  # Set resonable defaults for a new condition update event
  def set_defaults
    super
  end

  def create_depreciation_entry
    self.asset.depreciation_entries.create!(description: self.comments, book_value: self.book_value, event_date: self.event_date)
  end
  
end
