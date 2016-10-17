class FundingBucket< ActiveRecord::Base

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
    "#{self.id}_#{self.fiscal_year}_#{self.owner_id}_#{self.funding_template_id} #{self.description}"
  end

  def budget_remaining
    self.budget_amount - self.budget_committed
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
    self.active = self.active.nil? ? true : self.active
  end
end