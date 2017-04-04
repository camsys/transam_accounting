#------------------------------------------------------------------------------
#
# Grant
#
# Represents a federal, state or other type of grant where the transit
# agency is the recipient.
#
#------------------------------------------------------------------------------
class Grant < ActiveRecord::Base

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
  # Every funding line item belongs to an organization
  belongs_to  :organization

  # Has a single funding source
  belongs_to  :funding_source

  # Has many grant purchases
  has_many :grant_purchases, :foreign_key => 'sourceable_id', :dependent => :destroy

  # Has many assets through grant purchases
  has_many :assets, :through => :grant_purchases

  # Has 0 or more documents. Using a polymorphic association. These will be removed if the Grant is removed
  has_many    :documents,   :as => :documentable, :dependent => :destroy

  # Has 0 or more comments. Using a polymorphic association, These will be removed if the project is removed
  has_many    :comments,    :as => :commentable,  :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,                    :presence => true
  validates :grant_number,                    :presence => true
  validates :fy_year,                         :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 1970}
  validates :funding_source,                  :presence => true
  validates :amount,                          :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :organization_id,
    :funding_source_id,
    :fy_year,
    :grant_number,
    :amount,
    :active
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :grant_number,
    :funding_source
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

  # Returns the amount that is not earmarked for operating assistance
  def non_operating_funds
    amount - operating_funds
  end

  # Returns the amount of the fund that is earmarked for operating assistance
  def operating_funds

    amount * (pcnt_operating_assistance / 100.0)

  end

  # Returns true if the funding line item is associated with a federal fund, false otherwise
  def federal?

    if funding_source
      funding_source.federal?
    else
      false
    end

  end

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

  def name
    grant_number.blank? ? 'N/A' : grant_number
  end

  def details
    if project_number.blank?
      "#{funding_source} #{fiscal_year} ($#{available})"
    else
      "#{funding_source} #{fiscal_year}: #{project_number} ($#{available})"
    end
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

  # Set resonable defaults for a new grant
  def set_defaults

    self.amount ||= 0

    # Set the fiscal year to the current fiscal year
    self.fy_year ||= current_fiscal_year_year
    self.amount ||= 0
  end

end
