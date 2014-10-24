module TransamAccounting
  module TransamDepreciable
  #------------------------------------------------------------------------------
  #
  # Depreciable
  #
  # Injects methods and associations for depreciating assets and tracking depreciable
  # values.
  #
  # Usage:
  #
  #   Add the following line to an asset class
  #
  #   Include TransamDepreciable
  #
  # Model
  #
  #   The following properties are injected into the Asset Model
  #
  #
  #   :depreciable?      -- true if the asset is depreciable, false otherwise. Most
  #                         assets are depreciable (default) but in some cases like
  #                         land etc. the assets are not.
  #
  #   :property_type     -- boolean, true if the asset is depreciable, false otherwise
  #
  #   :depreciation_state_date -- the date that the asset starts depreciating. This is
  #                         usually the same as the in_service_date but can be changed
  #                         depending on specific needs.
  #
  #   :current_depreciation_date -- the date that the book value for the asset is calculated
  #                         for. This is generally the last day of the tax year.
  #
  #   :book_value        -- the depreciated value of the asset as of the current_depreciation_date
  #
  #   :salvage_value     -- the salvage value of the asset as of the current_depreciation_date
  #
  #   :replacement_value -- the cost of replacing the asset as of the current_depreciation_date
  #                         This value can be calculated from the policy or input by
  #                         the user.
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

  # returns true if this asset instance is depreciable, false
  # otherwise
  def depreciable?
    property_type
  end
                
  end
end  
ActiveRecord::Base.send(:include, TransamAccounting::TransamDepreciable) if defined?(Asset)
