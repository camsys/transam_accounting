#------------------------------------------------------------------------------
#
# GrantBudget
#
# Represents the join between a general ledge account and a grant
#
#------------------------------------------------------------------------------
class GrantBudget < ActiveRecord::Base

  SOURCEABLE_TYPE = Rails.application.config.asset_purchase_source

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  belongs_to  :general_ledger_account
  belongs_to  :sourceable, :polymorphic => true

  # Has many grant purchases
  has_many :grant_purchases, :as => :sourceable, :dependent => :destroy
  has_many :assets, :through => :grant_purchases


  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :general_ledger_account,    :presence => true
  validates :sourceable,                     :presence => true
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
    name
  end
  
  def name
    "#{sourceable} - #{general ledger_account}"
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

end
