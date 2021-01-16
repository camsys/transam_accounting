# --------------------------------
# # NOT USED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------


class GeneralLedgerAccountEntry < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to :general_ledger_account
  belongs_to :asset, class_name: Rails.application.config.asset_base_class_name

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :general_ledger_account,              :presence => true
  validates :description,                         :presence => true
  validates :event_date,                          :presence => true

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  default_scope { order(:event_date) }

  scope :from_fy, -> (fy_year) {  where('event_date >= ?', GeneralLedgerAccountEntry.new.start_of_fiscal_year(fy_year)) }

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

  def as_json(options={})
    super(options).merge!({
        general_ledger_account_object_key: general_ledger_account.object_key,
        general_ledger_account_account_number: general_ledger_account.account_number,
        asset_organization: asset.try(:organization).try(:short_name),
        asset: asset.try(:asset_tag)
    })
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
