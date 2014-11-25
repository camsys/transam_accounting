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
    #   :depreciable     -- boolean, true if the asset is depreciable, false otherwise
    #
    #   :depreciation_start_date -- the date that the asset starts depreciating. This is
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

      #------------------------------------------------------------------------------
      # Callbacks
      #------------------------------------------------------------------------------
      after_initialize  :set_depreciation_defaults

      #----------------------------------------------------
      # Associations
      #----------------------------------------------------


      #----------------------------------------------------
      # Validations
      #----------------------------------------------------

      alias_attribute :replacement_value, :estimated_replacement_cost

      validates  :depreciation_start_date,    :presence => true
      validates  :current_depreciation_date,  :presence => true
      validates  :book_value,                 :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
      validates  :salvage_value,              :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
      validates  :replacement_value,          :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
      validates_inclusion_of :depreciable, :in => [true, false]

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

    def get_depreciation_table

      if depreciation_start_date.nil? or current_depreciation_date.nil?
        return []
      end

      # Make sure we are working with a concrete asset class
      asset = is_typed? ? self : Asset.get_typed_asset(self)

      # see what metric we are using for the depreciated value of the asset
      class_name = policy.depreciation_calculation_type.class_name

      # create an instance of this calculator class
      calculator_instance = class_name.constantize.new

      # get date intervals for calculating depreciation
      date_interval_months = policy.depreciation_interval_type.months
      intervals = []

      if date_interval_months == 12
        interval = fiscal_year_end_date(depreciation_start_date)
      else
        interval = depreciation_start_date.end_of_month
      end

      # get list of past date intervals not including current_depreciation_date
      while interval <= current_depreciation_date - date_interval_months.months
        intervals << interval

        # get next interval
        # round to end of month to deal with varying month lengths (ex: Feb)
        interval = (interval + date_interval_months.months).end_of_month
      end

      # initialize table of results
      table = Array.new

      intervals.each do |interval|
        if date_interval_months == 12
          timestep = fiscal_year(fiscal_year_year_on_date(interval))
        else
          timestep = interval
        end
        book_value_start = calculator_instance.book_value_start(asset, interval)
        depreciated_expense = calculator_instance.depreciated_expense(asset, interval)
        book_value_end = calculator_instance.book_value_end(asset, interval)
        accumulated_depreciation = calculator_instance.accumulated_depreciation(asset, interval)

        data = {
          :timestep => timestep,
          :book_value_start => book_value_start,
          :depreciated_expense => depreciated_expense,
          :book_value_end => book_value_end,
          :accumulated_depreciation => accumulated_depreciation
        }
        table << data
      end

      return table
    end

    protected

      # updates the estimated value of an asset
      def update_asset_value(policy = nil)
        Rails.logger.info "Updating estimated value for asset = #{object_key}"

        # Make sure we are working with a concrete asset class
        asset = is_typed? ? self : Asset.get_typed_asset(self)

        # Get the policy to use
        policy = policy.nil? ? asset.policy : policy

        # exit if we can find a policy to work on
        if policy.nil?
          Rails.logger.warn "Can't find a policy for asset = #{object_key}"
          return
        end

        begin
          # see what metric we are using to determine the service life of the asset
          class_name = policy.depreciation_calculation_type.class_name
          asset.estimated_value = calculate(asset, policy, class_name)
          # save changes to this asset
          asset.save
        rescue Exception => e
          Rails.logger.warn e.message
        end
      end

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

      # Set resonable defaults for a new asset
      def set_depreciation_defaults
        if self.depreciation_start_date.nil?
          self.depreciation_start_date = self.purchase_date.nil? ? Date.today : self.purchase_date
        end

        self.current_depreciation_date ||= fiscal_year_end_date(Date.today)

        self.book_value ||= 0
        self.salvage_value ||= 0
        self.replacement_value ||= 0
        self.depreciable ||= true

      end

      #------------------------------------------------------------------------------
      #
      # Private Methods
      #
      #------------------------------------------------------------------------------
      private

  end

end
