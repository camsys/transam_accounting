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

  def self.find_existing_buckets_from_proxy funding_template_id, start_fiscal_year, end_fiscal_year, owner_id
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
      if(funding_template.organizations.length > 0)
        orgs = funding_template.organizations
      else
        grantor = Grantor.first
        orgs =  Organization.where(" id <> #{grantor.id} AND active = true")
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