#------------------------------------------------------------------------------
#
# GrantBudget
#
# Represents the join between a general ledge account and a grant
#
#------------------------------------------------------------------------------
class GrantBudget < ActiveRecord::Base

  SOURCEABLE_TYPE = Rails.application.config.grant_budget_source

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to  :sourceable, :polymorphic => true
  belongs_to  :general_ledger_account

  # Has many grant purchases
  has_many :grant_purchases, :as => :sourceable, :dependent => :destroy
  has_many :assets, :through => :grant_purchases


  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates_presence_of :sourceable
  validates_presence_of :general_ledger_account
  validates :amount,                    :allow_nil => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}

  # List of hash parameters specific to this class that are allowed by the controller
  FORM_PARAMS = [
    :id,
    :general_ledger_account_id,
    :sourceable_type,
    :sourceable_id,
    :amount,
    :_destroy
  ]

  scope :active, -> { where(:active => true) }

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
    "#{sourceable} #{general_ledger_account}"
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
    self.active = self.active.nil? ? true : self.active
  end

end
