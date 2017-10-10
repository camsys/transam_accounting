class GeneralLedgerMapping < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :chart_of_account
  belongs_to :asset_subtype
  belongs_to :asset_account, :class_name => 'GeneralLedgerAccount'
  belongs_to :depr_expense_account, :class_name => 'GeneralLedgerAccount'
  belongs_to :accumulated_depr_account, :class_name => 'GeneralLedgerAccount'
  belongs_to :gain_loss_account, :class_name => 'GeneralLedgerAccount'

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :chart_of_account,                   :presence => true
  validates :asset_subtype,                      :presence => true
  validates :asset_account,                      :presence => true
  validates :depr_expense_account,               :presence => true
  validates :accumulated_depr_account,           :presence => true
  validates :gain_loss_account,                  :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :asset_subtype_id,
      :asset_account_id,
      :depr_expense_account_id,
      :accumulated_depr_account_id,
      :gain_loss_account_id
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


  protected

  def set_defaults

  end

end
