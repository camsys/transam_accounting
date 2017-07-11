#------------------------------------------------------------------------------
#
# Grant
#
# Represents a federal, state or other type of grant where the transit
# agency is the recipient.
#
#------------------------------------------------------------------------------
class Grant < ActiveRecord::Base

  SOURCEABLE_TYPE = Rails.application.config.grant_source

  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults
  after_create                      :set_general_ledger_accounts

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every funding line item belongs to an organization
  belongs_to  :organization

  # Has a single funding source
  belongs_to  :sourceable, :polymorphic => true

  # Has many grant purchases
  has_many :grant_purchases, :as => :sourceable, :dependent => :destroy
  has_many :assets, :through => :grant_purchases

  # Has many grant purchases
  has_many :grant_budgets, :dependent => :destroy, :inverse_of => :grant

  # Allow the form to submit grant budgets
  accepts_nested_attributes_for :grant_budgets, :reject_if => :all_blank, :allow_destroy => true

  has_many :general_ledger_accounts

  # Has 0 or more documents. Using a polymorphic association. These will be removed if the Grant is removed
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  # Has 0 or more comments. Using a polymorphic association, These will be removed if the project is removed
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,                    :presence => true
  validates :fy_year,                         :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1970}
  validates :sourceable,                      :presence => true
  validates :amount,                          :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  scope :active, -> { where(:active => true) }

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :organization_id,
    :sourceable_type,
    :sourceable_id,
    :name,
    :fy_year,
    :amount,
    :active,
    :grant_budgets_attributes => [GrantBudget.allowable_params]
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :sourceable,
    :name
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.sourceable_type
    SOURCEABLE_TYPE
  end

  def self.sources(params=nil)
    if params
      SOURCEABLE_TYPE.constantize.where(params)
    else
      SOURCEABLE_TYPE.constantize.active
    end
  end

  def self.label
    if SOURCEABLE_TYPE == 'FundingSource'
      'Funding Program'
    else
      SOURCEABLE_TYPE.constantize.model_name.human.titleize
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Calculate the anount of the grant that has been spent on assets to date. This calculates
  # only the federal percentage
  def spent
    val = 0
    grant_purchases.includes(:asset).each do |p|
      val += p.asset.purchase_cost * (p.pcnt_purchase_cost / 100.0)
    end

    val
  end

  # Returns the balance of the fund. If the account is overdrawn
  # the amount will be < 0
  def balance
    amount - spent
  end

  # Returns the amount of funds available. This will return 0 if the account is overdrawn
  def available
    [balance, 0].max
  end

  # NOT COMPLETE
  # # Returns the amount that is not earmarked for operating assistance
  # def non_operating_funds
  #   amount - operating_funds
  # end
  #
  # # Returns the amount of the fund that is earmarked for operating assistance
  # def operating_funds
  #
  #   amount * (pcnt_operating_assistance / 100.0)
  #
  # end

  # Override the mixin method and delegate to it
  def fiscal_year(year = nil)
    if year
      super(year)
    else
      super(fy_year)
    end
  end

  def to_s
    name
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  def sourceable_path
    "#{sourceable_type.underscore}_path(:id => '#{sourceable.object_key}')"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new grant
  def set_defaults
    # Set the fiscal year to the current fiscal year
    self.fy_year ||= current_fiscal_year_year
    self.amount ||= 0
    self.active = self.active.nil? ? true : self.active
  end

  def set_general_ledger_accounts
    OrganizationGeneralLedgerAccount.active.each do |general_gla|
      if general_gla.grant_budget_specific
        acct_num = "#{general_gla.account_number}-#{self.to_s}"
        if GeneralLedgerAccount.find_by(chart_of_account_id: ChartOfAccount.find_by(organization: organization).id, account_number: acct_num, grant_id: self.id).nil?
          gla = GeneralLedgerAccount.create!(chart_of_account_id: ChartOfAccount.find_by(organization: organization).id, general_ledger_account_type_id: general_gla.general_ledger_account_type_id, general_ledger_account_subtype_id: general_gla.general_ledger_account_subtype_id, account_number: acct_num, name: "#{general_gla.name} #{self.to_s}", grant_id: self.id)
        end
      end
    end
  end

end
