class GeneralLedgerAccountEntry < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to :general_ledger_account
  belongs_to  :sourceable, :polymorphic => true

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :general_ledger_account,              :presence => true
  validates :description,                         :presence => true

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.sourceable_type
    SOURCEABLE_TYPE
  end

  def self.sources(params=nil)
    if params
      SOURCEABLE_TYPE.constantize.where(params)
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

  def to_s
    description
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

  # Set resonable defaults for general ledger account entries
  def set_defaults
    self.amount ||= 0
  end
end
