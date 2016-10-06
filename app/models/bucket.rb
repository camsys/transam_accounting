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
  belongs_to :bucket_type
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
      :bucket_type_id,
      :owner_id,
      :budget_amount,
      :budget_committed,
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
    "#{self.id}_#{self.fiscal_year}_#{self.owner_id}_#{self.template_id} #{self.description}"
  end

  def budget_remaining
    self.budget_amount - self.budget_committed
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