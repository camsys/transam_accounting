#------------------------------------------------------------------------------
#
# FundingSource
#
# Represents a funding source used to purchase assets. Each funding source can
# be associated with 0 or more grants
#
#------------------------------------------------------------------------------
class FundingSource < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Has a single funding source type
  belongs_to  :funding_source_type

  # Each funding source was created and updated by a user
  belongs_to :creator, :class_name => "User", :foreign_key => :created_by_id
  belongs_to :updator, :class_name => "User", :foreign_key => :updated_by_id

  # Each funding program has zero or more documents. Documents are deleted when the program is deleted
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  # Each funding program has zero or more comments. Documents are deleted when the program is deleted
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  # Has many grants
  has_many    :grants, -> { order(:fy_year) }, :dependent => :destroy

  has_many    :funding_templates, :dependent => :destroy
  #has_many    :funding_buckets, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :name,                      :presence => true
  validates :description,               :presence => true
  validates :funding_source_type,       :presence => true

  validates :life_in_years,             :allow_nil => true, :numericality => {:greater_than_or_equal_to => 1, :only_integer => true}
  validates :match_required,            :presence => true, :numericality => {:greater_than => 0.0, :less_than_or_equal_to => 100.0}
  validates :fy_start,                  :allow_nil => true, :numericality => {:greater_than_or_equal_to => SystemConfig.instance.epoch.year.to_i, :only_integer => true}
  validates :fy_end,                    :allow_nil => true, :numericality => {:greater_than_or_equal_to => SystemConfig.instance.epoch.year.to_i, :only_integer => true}

  validate :validate_fy_start_less_than_or_equal_fy_end
  validate :validate_either_formula_or_discretionary

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :name,
    :description,
    :details,
    :funding_source_type_id,
    :life_in_years,
    :match_required,
    :fy_start,
    :fy_end,
    :formula_fund,
    :discretionary_fund,
    :active
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.active
    where('(fy_start IS NULL OR fy_start <= ?) AND (fy_end IS NULL OR fy_end >= ?)', current_fiscal_year_year, current_fiscal_year_year)
  end

  def self.current_fiscal_year_year
    FundingSource.new.current_fiscal_year_year
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def deleteable?

    # any bucket/grant must be associated with a template and therefore only need to check template count
    funding_templates.count == 0
  end

  # Generates a cash forecast for the funding source
  def cash_forecast(org_id = nil)

    if org_id
      line_items = funding_line_items.where('organization_id = ?', org_id)
    else
      line_items = funding_line_items
    end

    first_year = line_items.empty? ? current_fiscal_year_year : line_items.first.fy_year

    a = []
    cum_amount = 0
    cum_spent = 0
    cum_committed = 0

    (first_year..last_fiscal_year_year).each do |yr|
      year_amount = 0
      year_spent = 0
      year_committed = 0

      list = line_items.where('fy_year = ?', yr)
      list.each do |fli|
        year_amount += fli.amount
        year_spent += fli.spent
        year_committed += fli.committed
      end

      cum_amount += year_amount
      cum_spent += year_spent
      cum_committed += year_committed

      # Add this years summary to the cumulative amounts
      a << [fiscal_year(yr), cum_amount, cum_spent, cum_committed]
    end
    a

  end

  # Generates a cash flow for the funding source
  def cash_flow(org = nil)

    if org
      line_items = grants.where('organization_id = ?', org.id)
    else
      line_items = grants
    end

    first_year = line_items.empty? ? current_fiscal_year_year : line_items.first.fy_year

    a = []
    balance = 0

    (first_year..last_fiscal_year_year).each do |yr|
      year_amount = 0
      year_spent = 0
      year_committed = 0

      list = line_items.where('fy_year = ?', yr)
      list.each do |fli|
        year_amount += fli.amount
        year_spent += fli.spent
        year_committed += fli.committed
      end

      balance += year_amount - (year_spent + year_committed)

      # Add this years summary to the array
      a << [fiscal_year(yr), year_amount, year_spent, year_committed, balance]
    end
    a

  end

  def federal?
    (funding_source_type_id == FundingSourceType.find_by(name: 'Federal').id)
  end

  def to_s
    name
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end

  def validate_fy_start_less_than_or_equal_fy_end
    valid = true
    if self.fy_start.present? && self.fy_end.present?
      valid = (fy_start <= fy_end)
    end

    valid
  end

  def validate_either_formula_or_discretionary
    self.formula_fund || self.discretionary_fund
  end
end
