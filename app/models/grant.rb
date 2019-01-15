#------------------------------------------------------------------------------
#
# Grant
#
# Represents a federal, state or other type of grant where the transit
# agency is the recipient.
#
#------------------------------------------------------------------------------
class Grant < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear

  include TransamWorkflow

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to  :owner, class_name: 'Organization'
  belongs_to  :contributor, class_name: 'Organization'

  # Has a single funding source
  belongs_to  :sourceable, :polymorphic => true

  has_many :grant_amendments

  # Has many grant purchases
  has_many :grant_purchases, :as => :sourceable, :dependent => :destroy
  has_many :assets, through: :grant_purchases, source: Rails.application.config.asset_base_class_name.underscore

  # Has many grant purchases
  has_many :grant_budgets, :dependent => :destroy, :inverse_of => :grant

  # Allow the form to submit grant budgets
  accepts_nested_attributes_for :grant_budgets, :reject_if => :all_blank, :allow_destroy => true

  has_many :general_ledger_accounts, :through => :grant_budgets

  belongs_to  :creator,     :class_name => "User",  :foreign_key => :created_by_user_id

  belongs_to  :updater,     :class_name => "User",  :foreign_key => :updated_by_user_id


  #------------------------------------------------------------------------------
  #
  # State Machine
  #
  # Used to track the state of a grant through the workflow process
  #
  #------------------------------------------------------------------------------
  state_machine :state, :initial => :in_development do

    #-------------------------------
    # List of allowable states
    #-------------------------------

    state :in_development

    state :open

    state :closed

    #---------------------------------------------------------------------------
    # List of allowable events. Events transition a Grant from one state to another
    #---------------------------------------------------------------------------

    event :publish do
      transition [:in_development] => :open
    end

    event :close do
      transition [:open] => :closed
    end

    event :reopen do
      transition [:closed] => :open
    end

    # Callbacks
    before_transition do |form, transition|
      Rails.logger.debug "Transitioning #{form} from #{transition.from_name} to #{transition.to_name} using #{transition.event}"
    end
  end

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :owner,                           :presence => true
  validates :grant_num,                       :presence => true, :uniqueness => true
  validates :fy_year,                         :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1970}
  validates :sourceable,                      :presence => true
  validates :amount,                          :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :award_date,                      :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  scope :active, -> { where(:active => true) }

  # default scope

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :owner_id,
    :contributor_id,
    :other_contributor,
    :has_multiple_contributors,
    :global_sourceable,
    :sourceable_type,
    :sourceable_id,
    :grant_num,
    :fy_year,
    :award_date,
    :amount,
    :legislative_authorization,
    :over_allocation_allowed,
    :active,
    :grant_budgets_attributes => [GrantBudget.allowable_params]
  ]

  # List of fields which can be searched using a simple text-based search
  SEARCHABLE_FIELDS = [
    :object_key,
    :sourceable,
    :grant_num
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

  def funding_source
    sourceable_type == 'FundingSource' ? sourceable : sourceable.funding_source
  end
  
  def global_sourceable
    self.sourceable.to_global_id if self.sourceable.present?
  end
  def global_sourceable=(sourceable)
    self.sourceable=GlobalID::Locator.locate sourceable
  end

  # Calculate the anount of the grant that has been spent on assets to date. This calculates
  # only the federal percentage
  def spent
    GrantPurchase.where(sourceable: self).to_a.sum{ |gp| gp.asset.purchase_cost * gp.pcnt_purchase_cost / 100.0 }
  end

  # Returns the balance of the fund. If the account is overdrawn
  # the amount will be < 0
  def balance
    amount - spent
  end

  # Returns the amount of funds available. This will return 0 if the account is overdrawn
  def available
    [balance, 0].max
  end

  # NOT COMPLETE
  # # Returns the amount that is not earmarked for operating assistance
  # def non_operating_funds
  #   amount - operating_funds
  # end
  #
  # # Returns the amount of the fund that is earmarked for operating assistance
  # def operating_funds
  #
  #   amount * (pcnt_operating_assistance / 100.0)
  #
  # end

  def closeout_date
    workflow_events.where(event_type: 'close').last.try(:created_at).try(:to_date)
  end

  def to_s
    grant_num
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
    # Set the fiscal year to the current fiscal year
    self.has_multiple_contributors = self.has_multiple_contributors.nil? ? false : true
    self.fy_year ||= current_fiscal_year_year
    self.amount ||= 0
    self.active = self.active.nil? ? true : self.active
  end

end
