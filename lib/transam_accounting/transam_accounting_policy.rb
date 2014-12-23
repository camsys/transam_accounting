module TransamAccounting
  module TransamAccountingPolicy
    #------------------------------------------------------------------------------
    #
    # Accountable
    #
    # Injects methods and associations for depreciating assets into an
    # Policy class
    #
    # Model
    #
    #------------------------------------------------------------------------------
    extend ActiveSupport::Concern

    included do

      #------------------------------------------------------------------------------
      # Callbacks
      #------------------------------------------------------------------------------
      after_initialize  :set_depreciation_defaults

      # ----------------------------------------------------
      # Associations
      # ----------------------------------------------------

      # Has a single method for calculating asset depreciation
      belongs_to  :depreciation_calculation_type

      # Has a time interval for how often depreciation is calculated
      belongs_to  :depreciation_interval_type

      # ----------------------------------------------------
      # Validations
      # ----------------------------------------------------
      validates :depreciation_calculation_type,  :presence => true
      validates :depreciation_interval_type,     :presence => true

      # List of hash parameters allowed by the controller
      FORM_PARAMS = [
        :depreciation_calculation_type_id,
        :depreciation_interval_type_id
      ]

    end

    #------------------------------------------------------------------------------
    #
    # Class Methods
    #
    #------------------------------------------------------------------------------

    module ClassMethods

    end

    #------------------------------------------------------------------------------
    #
    # Instance Methods
    #
    #------------------------------------------------------------------------------

    # Based on today's date, this method returns the current depreciation date.
    # this is the last date that depreciation should be calculated for based on
    # the setting in this policy
    def current_depreciation_date
      if depreciation_interval_type.id == 3
        # monthly
        d = (Date.today - 1.month).end_of_month
      elsif depreciation_interval_type.id == 2
        # quarterly
        d = (Date.today - 3.months).end_of_quarter
      else
        # default to end of the fiscal year
        d = fiscal_year_end_date(Date.today - 1.year)
      end
      d
    end

    protected
      # Set resonable defaults for the policy
      def set_depreciation_defaults
        self.depreciation_calculation_type ||= DepreciationCalculationType.find_by_name('Straight Line')
        self.depreciation_interval_type ||= DepreciationIntervalType.find_by_name('Annually')
      end

  end
end
