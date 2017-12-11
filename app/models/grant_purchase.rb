#------------------------------------------------------------------------------
#
# GrantPurchase
#
# Tracks asset purchases against specific funding. Each purchase tracks the percentage
# of the asset cost against the funding.
#
#------------------------------------------------------------------------------
class GrantPurchase < ActiveRecord::Base

  SOURCEABLE_TYPE = Rails.application.config.asset_purchase_source

  # Include the fiscal year mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every grant purchase is associated with an asset and some form of funding (sourceable)
  belongs_to  :sourceable, :polymorphic => true
  belongs_to  :asset

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates_presence_of :sourceable
  validates_presence_of :asset
  validates :pcnt_purchase_cost,  :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :id,
    :asset_id,
    :sourceable_type,
    :sourceable_id,
    :pcnt_purchase_cost,
    :_destroy
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  def self.sourceable_type
    SOURCEABLE_TYPE
  end

  def self.sources(params=nil)
    if params
      # check whether params are valid
      params = params.stringify_keys

      # override special case if sourceable type is GrantBudget
      clean_params = params.slice(*(params.keys & SOURCEABLE_TYPE.constantize.column_names))
      SOURCEABLE_TYPE.constantize.where(clean_params)

    else
      SOURCEABLE_TYPE.constantize.active
    end
  end

  def self.label
    if SOURCEABLE_TYPE == 'FundingSource'
      'Funding Program'
    else
      SOURCEABLE_TYPE.constantize.model_name.human.titleize
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Virtual attribute for setting a grant by its ID so we can patch around
  # a limitation in the accepts_nested_attributes_for
  def sourceable_id=(val)
    self.sourceable = SOURCEABLE_TYPE.constantize.find(val)
  end
  def sourceable_id
    sourceable.try(:id)
  end

  def to_s
    name
  end

  def name
    "#{sourceable}: #{pcnt_purchase_cost}%"
  end

  def sourceable_path
    "#{sourceable_type.underscore}_path(id: '#{sourceable.object_key}')"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults

  end



end
