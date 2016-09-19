#------------------------------------------------------------------------------
#
# GrantPurchase
#
# Tracks asset purchases against specific grants. Each purchase tracks the percentage
# of the asset cost against the grant.
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
  # Every grant purchase is associated with an asset and a grant
  belongs_to  :grant
  belongs_to  :asset

  #accepts_nested_attributes_for :grant

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates_presence_of :grant
  validates_presence_of :asset
  validates :pcnt_purchase_cost,  :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :id,
    :asset,
    :grant,
    :grant_id,
    :pcnt_purchase_cost
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

  # Virtual attribute for setting a grant by its ID so we can patch around
  # a limitation in the accepts_nested_attributes_for
  def grant_id=(val)
    self.grant = Grant.find(val)
  end
  def grant_id
    grant.id if grant
  end

  def to_s
    name
  end

  def name
    grant.blank? ? '' : "#{grant}: #{pcnt_purchase_cost}%"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new capital project
  def set_defaults

    self.pcnt_purchase_cost ||= 0

  end

end
