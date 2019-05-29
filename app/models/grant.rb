#------------------------------------------------------------------------------
#
# Grant
#
# Represents a federal, state or other type of grant where the transit
# agency is the recipient.
#
#------------------------------------------------------------------------------
class Grant < ActiveRecord::Base

  has_paper_trail on: [:create, :update], only: [:state, :fy_year, :sourceable_type, :sourceable_id, :amount]

  # Include the object key mixin
  include TransamObjectKey

  # Include the fiscal year mixin
  include FiscalYear

  include TransamWorkflow

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize                  :set_defaults

  before_save                       :update_grant_apportionments

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to  :owner, class_name: 'Organization'
  belongs_to  :contributor, class_name: 'Organization'

  # Has a single funding source
  belongs_to  :sourceable, :polymorphic => true

  has_many :grant_apportionments

  has_many :grant_amendments

  # Has many grant purchases
  has_many :grant_purchases, :as => :sourceable, :dependent => :destroy
  has_many :assets, through: :grant_purchases, source: Rails.application.config.asset_base_class_name.underscore

  # Has many grant purchases
  has_many :grant_budgets, :dependent => :destroy, :inverse_of => :grant

  # Allow the form to submit grant budgets
  accepts_nested_attributes_for :grant_budgets, :reject_if => :all_blank, :allow_destroy => true

  has_many :general_ledger_accounts, :through => :grant_budgets

  belongs_to  :creator, -> { unscope(where: :active) },     :class_name => "User",  :foreign_key => :created_by_user_id

  belongs_to  :updater, -> { unscope(where: :active) },     :class_name => "User",  :foreign_key => :updated_by_user_id


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
  scope :open, -> { where(state: 'open') }

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

  def self.formatted_version(version)
    if version.event == 'create'
      ver = [
          {
              datetime: version.created_at,
              event: "Apportionment Created",
              event_type: 'Created',
              comments: "Apportionment 'Primary' was created in the amount of #{ActiveSupport::NumberHelper.number_to_currency(version.changeset['amount'][1], precision: 0)}.",
              user: version.actor
          },
          {
              datetime: version.created_at,
              event: "Grant Created",
              event_type: 'Created',
              comments: "Grant is In Development.",
              user: version.actor
          }
      ]
    else
      if version.changeset.key? 'state'
        event = self.new.state_paths(:from => version.changeset['state'][0], :to => version.changeset['state'][1]).first.first.event.to_s

        ver = {
            datetime: version.created_at,
            event: "Grant #{event.titleize}#{event == 'close' ? 'd' : 'ed'}",
            event_type: 'Updated',
            comments: "Grant is #{version.changeset['state'][1].titleize}",
            user: version.actor
        }

        case version.changeset['state'][1]
          when 'open'
            ver[:comments] += ', and funds can be assigned to assets.'
          when 'closed'
            ver[:comments] += '. No further edits or assignment of funds can be made.'
          when 'reopened'
            ver[:comments] += ', and funds can be assigned to assets.'
        end

      else
        ver = {
            datetime: version.created_at,
            event: "Apportionment Updated",
            event_type: 'Updated',
            comments: "Apportionment 'Primary' was Updated.",
            user: version.actor
        }

        version.changeset.each do |key, val|
          if key.to_s == 'amount'
            ver[:comments] += " The #{key} was updated from #{ActiveSupport::NumberHelper.number_to_currency(val[0], precision: 0)} to #{ActiveSupport::NumberHelper.number_to_currency(val[1], precision: 0)}."
          else
            ver[:comments] += " The #{key} was updated from #{val[0]} to #{val[1]}."
          end
        end
      end
    end

    ver
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def grant_num

    grant_num_temp = nil

    grant_amendments.order(created_at: :desc).each do |amendment|
      grant_num_temp = amendment.grant_num
      break if grant_num_temp.present?
    end

    grant_num_temp = read_attribute(:grant_num) unless grant_num_temp.present?

    return grant_num_temp
  end

  def is_single_apportionment?
    true # TODO: add multiple
  end

  def open?
    state == 'open'
  end

  def updatable?
    ['in_development', 'open'].include? state
  end
  def deleteable?
    state == 'in_development'
  end

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
    GrantPurchase.where(sourceable: self).sum(:amount)
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

  # formats paper_trail versions
  def history
    PaperTrail::Version.where(item: [self, self.grant_apportionments, self.grant_amendments]).order(created_at: :desc).map{|v| v.item_type.constantize.formatted_version(v) }.flatten
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
    self.has_multiple_contributors = self.has_multiple_contributors.nil? ? false : self.has_multiple_contributors
    self.fy_year ||= current_fiscal_year_year
    self.amount ||= 0
    self.active = self.active.nil? ? true : self.active
  end

  def update_grant_apportionments
    if is_single_apportionment?
      if grant_apportionments.empty?
        grant_apportionments.build
      else
        grant_apportionments.update_all(sourceable_type: self.sourceable_type, sourceable_id: self.sourceable_id, amount: self.amount)
      end
    end
  end

end
