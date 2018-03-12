#------------------------------------------------------------------------------
#
# ChartOfAccount
#
# Represents a chart of accounts for an organization. Each org can have at most
# one chart of accounts which contains a list of the general ledger accounts for
# that organization.
#
#------------------------------------------------------------------------------
class ChartOfAccount < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  after_create      :activate_gl_reports

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------

  # Every chart of accounts belongs to an organization
  belongs_to :organization

  # Every Chart of Accounts has a set of General Ledger Accounts
  has_many    :general_ledger_accounts, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

  validates :organization,      :presence => true


  # List of allowable form param hash keys
  FORM_PARAMS = [
    :organization_id,
    :active
  ]

  #------------------------------------------------------------------------------
  #
  # Scopes
  #
  #------------------------------------------------------------------------------

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }

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

  def name
    "#{organization} Chart of Accounts"
  end
  def to_s
    name
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

    # Set resonable defaults for chart of accounts
    def set_defaults
      self.active = self.active.nil? ? true : self.active
    end

    # GL reports are deactivated in new transam instance
    # if a chart of account exists, GL features are enabled -- therefore need to activate reports
    def activate_gl_reports
      report_type = ReportType.find_by(name: "GL/Accounting Report")
      report_type.update!(active: true)

      report_type.reports.update_all(active: true)

    end


end
