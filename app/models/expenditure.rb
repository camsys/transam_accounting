# --------------------------------
# # NOT USED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

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
  #validates :organization,              :presence => true
  #validates :grant,                     :presence => true
  validates :expense_type,              :presence => true
  validates :expense_date,              :presence => true
  validates :description,               :presence => true
  validates :amount,                    :allow_nil => true, :numericality => {:only_integer => true}
  validates :pcnt_from_grant,           :allow_nil => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
      :general_ledger_account_id,
      :grant_id,
      :expense_type_id,
      :expense_date,
      :description,
      :amount,
      :extended_useful_life_months,
      :vendor,
      :asset_ids => []
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
      :object_key,
      :general_ledger_account,
      :grant,
      :expense_type,
      :name,
      :description,
      :vendor
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
    assets.each do |asset|
      changed_amount = (self.amount - self.amount_was.to_i)

      gl_mapping = asset.general_ledger_mapping

      if gl_mapping.present? # check whether this app records GLAs at all
        gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: expense_date, description: "CapEx: #{asset.asset_path} #{self.vendor}", amount: changed_amount, asset: asset)

        self.general_ledger_account.general_ledger_account_entries.create!(event_date: expense_date, description: "CapEx: #{asset.asset_path} #{self.vendor}", amount: -changed_amount, asset: asset) if self.general_ledger_account.present?
      end

      asset.depreciation_entries.create!(description: "CapEx: #{self.description}", book_value: changed_amount, event_date: expense_date)
      asset.update_columns(current_depreciation_date: expense_date)

      asset.depreciation_entries.depreciation_expenses.where('event_date > ?',self.expense_date).each do |depr_entry|
        if gl_mapping.present?
          gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: expense_date, description: "REVERSED Accumulated Depreciation: #{asset.asset_path}", amount: -depr_entry.book_value, asset: asset)

          gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: expense_date, description: "REVERSED Deprectiation Expense: #{asset.asset_path}", amount: depr_entry.book_value, asset: asset)
        end

        depr_entry.destroy!
      end

      asset.update_book_value
    end
  end


  # Set resonable defaults for a suppoert facility
  def set_defaults
    self.amount ||= 0
    self.extended_useful_life_months ||= 0
    self.pcnt_from_grant ||= 0
    self.expense_date ||= Date.today
  end

end