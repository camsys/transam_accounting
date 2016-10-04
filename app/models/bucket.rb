class Bucket< ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  # after_initialize  :set_defaults
  # before_save        :check_orgs_list


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :funding_template
  belongs_to :owner, :class_name => "Organization"

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :funding_template_id,       :presence => true
  # Validate owner_id is the organization is not state
  # validates :owner_id,                  :presence => true

  FORM_PARAMS = [
      :funding_template_id,
      :fiscal_year,
      :budget_amount,
      :owner_id,
      :description
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(bucket_id: FundingSource.active.ids) }

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
    self.all_organizations = self.all_organizations.nil? ? true : self.all_organizations
    self.active = self.active.nil? ? true : self.active
  end
end