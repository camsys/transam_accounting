class DepreciationEntry < ActiveRecord::Base

  # Include the object key mixin
  # Note: skipping uniquess constraint, see below
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  before_save       :check_description_length

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :asset
  belongs_to :transam_asset

  has_and_belongs_to_many :general_ledger_account_entries

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  #validates :asset,           :presence => true
  validates :description,     :presence => true
  validates :book_value,      :presence => true
  validates    :description,  :uniqueness => { :scope => [:transam_asset_id, :event_date]}


  # List of allowable form param hash keys
  FORM_PARAMS = [
      :asset_id,
      :description,
      :book_value,
      :event_date
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  default_scope { order(:event_date) }

  scope :depreciation_expenses, -> { where("description LIKE 'Depreciation Expense%'") }
  scope :manual_adjustments, -> { where("description LIKE 'Manual%'") }
  scope :capex, -> { where("description LIKE 'CapEx%'") }
  scope :rehab, -> { where("description LIKE 'Rehab%'") }

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
    description
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected


  def set_defaults

  end

  def check_description_length
    if self.description.length > 255
      self.description = self.description[0..254]
    end
  end

  def skip_uniqueness?
    true
  end
end
