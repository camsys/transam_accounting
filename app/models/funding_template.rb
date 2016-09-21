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
  validates :name,                      :presence => true
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
      :all_organizations,
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

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end

  def check_orgs_list
    # clear out orgs list if template is applicable to all orgs
    self.organizations = [] if self.all_organizations
  end
end
