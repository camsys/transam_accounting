module TransamAccounting
  module TransamDepreciable
    #------------------------------------------------------------------------------
    #
    # Depreciable
    #
    # Injects methods and associations for depreciating assets and tracking depreciable
    # values.
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

    # the amount of depreciation for the current accounting period
    def current_ytd_depreciation
      # Make sure we are working with a concrete asset class
      asset = is_typed? ? self : Asset.get_typed_asset(self)

      # see what metric we are using for the depreciated value of the asset
      class_name = policy.depreciation_calculation_type.class_name

      calculate(asset, policy, class_name, 'current_ytd_depreciation')
    end

    # the amount of depreciation for the previous accounting period
    def beginning_ytd_depreciation(asset)
      # Make sure we are working with a concrete asset class
      asset = is_typed? ? self : Asset.get_typed_asset(self)

      # see what metric we are using for the depreciated value of the asset
      class_name = policy.depreciation_calculation_type.class_name

      calculate(asset, policy, class_name, 'beginning_ytd_depreciation')
    end

    # the amount of accumulated depreciation for the previous accounting period
    def beginning_accumulated_depreciation(asset)
      # Make sure we are working with a concrete asset class
      asset = is_typed? ? self : Asset.get_typed_asset(self)

      # see what metric we are using for the depreciated value of the asset
      class_name = policy.depreciation_calculation_type.class_name

      calculate(asset, policy, class_name, 'beginning_accumulated_depreciation')
    end

    def get_depreciable_table
      # Make sure we are working with a concrete asset class
      asset = is_typed? ? self : Asset.get_typed_asset(self)

      # see what metric we are using for the depreciated value of the asset
      class_name = policy.depreciation_calculation_type.class_name

      # get FYs for calculating depreciation
      # get previous depreciation dates
      years = (depreciation_start_date.year..current_depreciation_date.year - 1)
              .to_a
              .map{ |d| Date.new(d, depreciation_start_date.month, depreciation_start_date.day) }

      # add current depreciation date to array of dates
      years << current_depreciation_date

      # initialize table of results
      table = Array.new

      years.each do |year|
        estimated_value = calculate(asset, policy, class_name, 'calculate',year)
        depreciated_value = calculate(asset, policy, class_name, 'depreciated_value',year)

        data = { :year => year, :estimated_value => estimated_value, :depreciated_value => depreciated_value }
        table << data
      end

      return table
    end

    protected

      # Update the asset depreciation model
      def update_asset_depreciated_state(policy = nil)
        # Update the depreciated and salvage value
        begin
          # Make sure we are working with a concrete asset class
          asset = is_typed? ? self : Asset.get_typed_asset(self)

          # see what metric we are using for the depreciated value of the asset
          class_name = policy.depreciation_calculation_type.class_name

          # caches depreciated value as an integer
          asset.book_value = calculate(asset, policy, class_name, 'depreciated_value').round(0)

          # caches residual value as an integer
          asset.salvage_value = calculate(asset, policy, class_name).round(0)
        rescue Exception => e
          Rails.logger.warn e.message
        end
      end

      #------------------------------------------------------------------------------
      #
      # Private Methods
      #
      #------------------------------------------------------------------------------
      private

      # Calls a calculate method on a Calculator class to perform a condition or cost calculation
      # for the asset. The method name defaults to x.calculate(asset) but other methods
      # with the same signature can be passed in
      def calculate(asset, policy, class_name, target_method = 'calculate',on_date=nil)
        begin
          Rails.logger.debug "#{class_name}, #{target_method}"
          # create an instance of this class and call the method
          calculator_instance = class_name.constantize.new
          Rails.logger.debug "Instance created #{calculator_instance}"
          method_object = calculator_instance.method(target_method)
          Rails.logger.debug "Instance method created #{method_object}"
          method_object.call(asset,on_date)
        rescue Exception => e
          Rails.logger.error e.message
          raise RuntimeError.new "#{class_name} calculation failed for asset #{asset.object_key} and policy #{policy.name}"
        end
      end
  end

end
