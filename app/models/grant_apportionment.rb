class GrantApportionment < ApplicationRecord

  has_paper_trail on: [:update], only: [:name, :fy_year]

  # Include the object key mixin
  include TransamObjectKey
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to :grant

  # Has a single funding source
  belongs_to  :sourceable, :polymorphic => true

  belongs_to  :creator, -> { unscope(where: :active) },     :class_name => "User",  :foreign_key => :created_by_user_id

  belongs_to  :updater, -> { unscope(where: :active) },     :class_name => "User",  :foreign_key => :updated_by_user_id

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :name,                            :presence => true
  validates :fy_year,                         :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1970}
  validates :sourceable,                      :presence => true
  validates :amount,                          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :sourceable_type,
      :sourceable_id,
      :name,
      :fy_year,
      :amount
  ]

  SEARCHABLE_FIELDS =[]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.formatted_version(version)
    ver = {
        datetime: version.created_at,
        event: "Apportionment Updated",
        event_type: 'Updated',
        comments: "Apportionment '#{version.reify.paper_trail.next_version.name}' was Updated.",
        user: version.actor
    }

    version.changeset.each do |key, val|
      ver[:comments] += " The #{key} was updated from #{val[0]} to #{val[1]}."
    end

    ver
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def funding_source
    sourceable_type == 'FundingSource' ? sourceable : sourceable.funding_source
  end

  def global_sourceable
    self.sourceable.to_global_id if self.sourceable.present?
  end
  def global_sourceable=(sourceable)
    self.sourceable=GlobalID::Locator.locate sourceable
  end

  def to_s
   name
  end

  def searchable_fields
    SEARCHABLE_FIELDS
  end

  def sourceable_path
    "#{sourceable_type.underscore}_path(:id => '#{sourceable.object_key}')"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new grant
  def set_defaults

    # first apportionment
    if self.grant.present? && self.grant.grant_apportionments.count == 0
      self.sourceable ||= self.grant.sourceable
      self.name ||= 'Primary'
      self.fy_year ||= self.grant.fy_year
      self.amount ||= self.grant.amount
      self.created_by_user_id ||= self.grant.created_by_user_id
      self.updated_by_user_id ||= self.grant.updated_by_user_id
    end
  end

end
