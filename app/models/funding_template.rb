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

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def to_s
    name
  end

  def set_funding_template_details(funding_template_proxy)
    unless funding_template_proxy.nil?
      self.object_key = funding_template_proxy.object_key
      self.funding_source_id = funding_template_proxy.funding_source_id
      self.name = funding_template_proxy.name
      self.external_id = funding_template_proxy.external_id
      self.description = funding_template_proxy.description
      self.contributor_id = funding_template_proxy.contributor_id
      self.owner_id = funding_template_proxy.owner_id
      self.transfer_only = funding_template_proxy.transfer_only
      self.recurring = funding_template_proxy.recurring
      self.match_required = funding_template_proxy.match_required
      self.active = funding_template_proxy.active
      if funding_template_proxy.all_organizations
        self.query_string = 'id > 0'
      elsif !funding_template_proxy.query_string.blank?
        self.query_string = funding_template_proxy.query_string
      end
      self.organization_ids = a.organization_ids
      self.funding_template_type_ids = a.funding_template_type_ids
    end
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
    self.organizations = [] if self.all_organizations
  end
end
