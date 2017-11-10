class DepreciationEntry < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :asset

  has_and_belongs_to_many :general_ledger_account_entries

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :asset,           :presence => true
  validates :description,     :presence => true
  validates :book_value,      :presence => true


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

end