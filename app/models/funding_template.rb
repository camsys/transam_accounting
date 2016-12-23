class FundingTemplate < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  before_save        :check_orgs_list


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :funding_source
  belongs_to :contributor, :class_name => "FundingSourceType"
  belongs_to :owner, :class_name => "FundingSourceType"
  has_and_belongs_to_many :funding_template_types,  :join_table => :funding_templates_funding_template_types
  has_and_belongs_to_many :organizations

  has_many :funding_buckets, :dependent => :destroy


  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :funding_source_id,         :presence => true
  validates :name,                      :presence => true, :uniqueness => {scope: :funding_source, message: "must be unique within a funding program"}
  validates :contributor_id,            :presence => true
  validates :owner_id,                  :presence => true
  validates :match_required,            :allow_nil => true, :numericality => {:greater_than => 0.0, :less_than_or_equal_to => 100.0}

  FORM_PARAMS = [
      :funding_source_id,
      :name,
      :external_id,
      :description,
      :contributor_id,
      :owner_id,
      :transfer_only,
      :recurring,
      :match_required,
      :active,
      :query_string,
      :organization_ids,
      :create_multiple_agencies,
      :create_multiple_buckets_for_agency_year,
      {:funding_template_type_ids=>[]}
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(funding_source_id: FundingSource.active.ids) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.get_templates_for_agencies org_ids
    templates = []

    self.active.where(contributor: FundingSourceType.find_by(name: 'Agency')).each do |t|
      templates << t if (t.get_organizations.map{|x| x.id} & org_ids).count > 0 # add template to list if one of orgs is in eligibility
    end

    templates
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def to_s
    name
  end

  def get_organizations
    self.query_string.present? ? Organization.find_by_sql(self.query_string) : self.organizations
  end


  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def set_defaults
    # self.all_organizations = self.all_organizations.nil? ? true : self.all_organizations
    self.active = self.active.nil? ? true : self.active
  end

  def check_orgs_list
    # clear out orgs list if template is applicable to all orgs
    self.organizations = [] if self.query_string.present?
  end
end
