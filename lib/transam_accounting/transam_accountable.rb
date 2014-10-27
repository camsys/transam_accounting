module TransamAccounting

  module TransamAccountable
    #------------------------------------------------------------------------------
    #
    # Accountable
    #
    # Injects methods and associations for managing depreciable assets into an 
    # Organization class
    #
    # Model
    #
    #------------------------------------------------------------------------------
    extend ActiveSupport::Concern
  
    included do
  
      # ----------------------------------------------------
      # Associations
      # ----------------------------------------------------

      # ----------------------------------------------------
      # Validations
      # ----------------------------------------------------
      
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
  
    # Retrieve the chart of accounts for this organization. Chart of accounts are designed
    # to be immutable thus we do it this way and not via an association
    def chart_of_accounts
      ChartOfAccount.where(:organization => self).first
    end
    
    protected

  end
end