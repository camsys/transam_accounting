#------------------------------------------------------------------------------
#
# GrantPurchase
#
# Tracks asset purchases against specific funding. Each purchase tracks the percentage
# of the asset cost against the funding.
#
#------------------------------------------------------------------------------
class GrantPurchase < ActiveRecord::Base

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
  belongs_to  :transam_asset

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates_presence_of :sourceable
  validates_presence_of Rails.application.config.asset_base_class_name.underscore.to_sym
  validates :pcnt_purchase_cost,  :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :id,
    :asset_id,
    :global_sourceable,
    :sourceable_type,
    :sourceable_id,
    :other_sourceable,
    :pcnt_purchase_cost,
    :expense_tag,
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

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def global_sourceable
    self.sourceable.to_global_id if self.sourceable.present?
  end
  def global_sourceable=(sourceable)
    self.sourceable=GlobalID::Locator.locate sourceable
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
