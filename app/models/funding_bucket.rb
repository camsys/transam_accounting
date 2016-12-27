class FundingBucket< ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  # before_save        :check_orgs_list


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Each funding source was created and updated by a user
  belongs_to :creator, :class_name => "User", :foreign_key => :created_by_id
  belongs_to :updator, :class_name => "User", :foreign_key => :updated_by_id

  belongs_to :funding_template
  has_one    :funding_source, :through => :funding_template
  belongs_to :owner, :class_name => "Organization"

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :funding_template_id,       :presence => true
  validates :fiscal_year,               :presence => true
  validates :budget_amount,             :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :owner_id,                  :presence => true


  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :object_key,
      :funding_template_id,
      :owner_id,
      :fiscal_year,
      :budget_amount,
      :description
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.find_existing_buckets_from_proxy funding_template_id, start_fiscal_year, end_fiscal_year, owner_id,  organizations_with_budgets
    # Start to set up the query
    conditions  = []
    values      = []
    existing_buckets = []

    conditions << 'funding_template_id = ?'
    values << funding_template_id

    conditions << 'fiscal_year >= ?'
    values << start_fiscal_year

    conditions << 'fiscal_year <= ?'
    values << end_fiscal_year

    if owner_id.to_i < 0
      funding_template = FundingTemplate.find_by(id: funding_template_id)

      conditions << 'owner_id IN (?)'
      orgs = []
      org_ids = []
      if funding_template.owner == FundingSourceType.find_by(name: 'State')
        orgs =  Grantor.active
      else

        organizations = funding_template.get_organizations
        if !organizations_with_budgets.nil? && organizations_with_budgets.length > 0
          organizations.each { |o|
            if organizations_with_budgets.include?(o.id.to_s)
              orgs << o
            end
          }
        else
          orgs = funding_template.get_organizations
        end

      end
      orgs.each { |o| org_ids << o.id }
      values << org_ids
    else
      conditions << 'owner_id = ?'
      values << owner_id
    end


    conditions << 'active = true'
    existing_buckets = FundingBucket.where(conditions.join(' AND '), *values)

    return existing_buckets
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def to_s
    "FY #{self.fiscal_year-2000}-#{self.fiscal_year-1999} #{self.owner.short_name}"

  end

  def budget_remaining
    self.budget_amount - self.budget_committed if self.budget_amount.present? && self.budget_committed.present?
  end

  def is_bucket_app?
    self.funding_template.contributor == FundingSourceType.find_by(name: 'Agency')
  end

  def set_values_from_proxy bucket_proxy, agency_id=nil
    self.funding_template_id = bucket_proxy.template_id
    self.fiscal_year = bucket_proxy.fiscal_year_range_start
    self.budget_amount = bucket_proxy.total_amount
    self.budget_committed = 0
    self.owner_id = agency_id.nil? ? bucket_proxy.owner_id : agency_id
    self.active=true

    funding_template = FundingTemplate.find_by(id: self.funding_template_id)
    owner = Organization.find_by(id: self.owner_id)

    if bucket_proxy.name.blank?
      self.name = "#{funding_template.funding_source.name}-#{funding_template.name}-#{owner.coded_name}-#{fiscal_year_for_name(self.fiscal_year)}"
    else
      self.name = "#{funding_template.funding_source.name}-#{funding_template.name}-#{owner.coded_name}-#{fiscal_year_for_name(self.fiscal_year)}-#{bucket_proxy.name}"
    end
  end

  def fiscal_year_for_name(year)
    yr = year - 2000
    first = "%.2d" % yr
    if yr == 99 # when yr == 99, yr + 1 would be 100, which causes: "FY 99-100"
      next_yr = 00
    else
      next_yr = (yr + 1)
    end
    last = "%.2d" % next_yr

    "FY#{first}/#{last}"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def set_defaults
    self.budget_committed ||= 0
    self.active = self.active.nil? ? true : self.active
  end

end