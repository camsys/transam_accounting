class FundingTemplate < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults


  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :funding_source
  belongs_to :contributer, :class_name => "FundingSourceType"
  belongs_to :owner, :class_name => "FundingSourceType"
  has_and_belongs_to_many :funding_template_types,  :join_table => :funding_templates_funding_template_types
  has_and_belongs_to_many :organizations


  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :funding_source_id,              :presence => true
  validates :name,                           :presence => true
  validates :contributer_id,                 :presence => true
  validates :owner_id,                       :presence => true

  FORM_PARAMS = [
      :funding_source_id,
      :name,
      :description,
      :contributer_id,
      :owner_id,
      :transfer_only,
      :recurring,
      :match_required,
      :active,
      :organization_ids,
      {:funding_template_type_ids=>[]}
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(active: true) }

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
end
