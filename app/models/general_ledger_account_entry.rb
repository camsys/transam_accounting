class GeneralLedgerAccountEntry < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to :general_ledger_account

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :general_ledger_account,              :presence => true
  validates :description,                         :presence => true
  validates :event_date,                          :presence => true

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------


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

  # Set resonable defaults for general ledger account entries
  def set_defaults
    self.amount ||= 0
    self.event_date ||= Date.today
  end
end
