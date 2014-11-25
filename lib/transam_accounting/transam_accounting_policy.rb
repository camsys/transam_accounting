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

    protected
      # Set resonable defaults for the policy
      def set_depreciation_defaults
        self.depreciation_calculation_type ||= DepreciationCalculationType.find_by_name('Straight Line')
        self.depreciation_interval_type ||= DepreciationIntervalType.find_by_name('Yearly')

      end

  end
end
