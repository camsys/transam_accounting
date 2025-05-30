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
  #validates_presence_of :sourceable
  validates_presence_of Rails.application.config.asset_base_class_name.underscore.to_sym
  validates :pcnt_purchase_cost,  :presence => true, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates_presence_of :fain, :if => :sourceable_federal_funding?
  validate :total_funding_not_over_purchase_cost

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
    :amount,
    :expense_tag,
    :fain,
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

  def sourceable_federal_funding?
    self.sourceable_type == "FundingSource" ? self.sourceable.federal? : false
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

  def total_funding_not_over_purchase_cost
    unless self._destroy
      existing_funding = self.sourceable_type == "FundingSource" ? self.transam_asset.funding_source_grant_purchases : self.transam_asset.grant_grant_purchases
      funding_total = 0

      existing_funding.each do |f|
        if !f._destroy
          funding_total += f.amount
        end
      end

      if funding_total > self.transam_asset.purchase_cost
        errors.add(:amount, ": total funding from #{self.sourceable_type.underscore.humanize.downcase}s cannot exceed 100% of purchase cost")
      end
    end
  end

end
