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
  
      # ----------------------------------------------------
      # Associations
      # ----------------------------------------------------

      # Has a single method for calculating asset depreciation
      belongs_to  :depreciation_calculation_type

      # ----------------------------------------------------
      # Validations
      # ----------------------------------------------------
      validates :depreciation_calculation_type,  :presence => true

      # List of hash parameters allowed by the controller
      FORM_PARAMS = [
        :depreciation_calculation_type_id
      ]

    end
  
    #------------------------------------------------------------------------------
    #
    # Class Methods
    #
    #------------------------------------------------------------------------------
  
    module ClassMethods
  
      def self.allowable_params
        FORM_PARAMS
      end

    end
  
    #------------------------------------------------------------------------------
    #
    # Instance Methods
    #
    #------------------------------------------------------------------------------
      
    protected

  end
end