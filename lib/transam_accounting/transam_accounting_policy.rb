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

    # Calculates the depreciation date based on the policy
    def depreciation_date(on_date = Date.today)
      if depreciation_interval_type.id == 3
        # monthly
        d = on_date.end_of_month
      elsif depreciation_interval_type.id == 2
        # quarterly
        d = (on_date - 2.months).end_of_quarter
      else
        # default to end of the fiscal year
        d = fiscal_year_end_date(on_date - 11.months)
      end
      d
    end

    # Based on today's date, this method returns the current depreciation date.
    # this is the last date that depreciation should be calculated for based on
    # the setting in this policy
    def current_depreciation_date
      depreciation_date(Date.today)
    end

    # Returns the next depreciation date for the org based on the policy they
    # have selected
    def next_depreciation_date
      current_depreciation_date + depreciation_interval_type.months.months
    end

    protected
      # Set resonable defaults for the policy
      def set_depreciation_defaults
        self.depreciation_calculation_type ||= DepreciationCalculationType.find_by_name('Straight Line')
        self.depreciation_interval_type ||= DepreciationIntervalType.find_by_name('Annually')
      end

  end
end
