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
  #   :salvage_value     -- the salvage value of the asset
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    #------------------------------------------------------------------------------
    # Callbacks
    #------------------------------------------------------------------------------
    before_validation  :set_depreciation_defaults
    before_update      :clear_depreciation_cache

    #----------------------------------------------------
    # Associations
    #----------------------------------------------------

    has_many :depreciation_entries, :foreign_key => :asset_id

    has_many   :book_value_updates, -> {where :asset_event_type_id => BookValueUpdateEvent.asset_event_type.id }, :class_name => "BookValueUpdateEvent",  :foreign_key => :asset_id

    #----------------------------------------------------
    # Validations
    #----------------------------------------------------

    alias_attribute :replacement_value, :estimated_replacement_cost

    validates  :depreciation_start_date,    :presence => true
    #validates  :current_depreciation_date,  :presence => true
    validates  :book_value,                 :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
    validates  :salvage_value,              :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
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

  # Render the asset as a JSON object -- overrides the default json encoding
  def depreciable_as_json(options={})
    {
      :depreciable => self.depreciable,
      :depreciation_start_date => self.depreciation_start_date,
      :book_value => self.book_value,
      :salvage_value => self.salvage_value,
      :depreciation_date => self.current_depreciation_date
    }
  end

  # returns the number of months the asset has depreciated
  def depreciation_months(on_date=Date.today, start_date=nil)
    if start_date.nil?
      start_date = depreciation_start_date
    end
    (on_date.year * 12 + on_date.month) - (start_date.year * 12 + start_date.month)
  end

  def get_depreciation_table

    # See if the table has already been created and cached
    table = get_cached_object('depreciation_table')
    if table.nil?
      if depreciation_start_date.nil?
        table = []
      else
        # Make sure we are working with a concrete asset class
        asset = is_typed? ? self : Asset.get_typed_asset(self)

        table = []
        asset.depreciation_entries.each_with_index do |depr_entry, idx|
          table << {
              :on_date => depr_entry.event_date,
              :depreciated_expense => idx > 0 ? asset.depreciation_entries[idx-1].book_value - depr_entry.book_value : '',
              :book_value_end => depr_entry.book_value,
              :accumulated_depreciation => asset.depreciation_purchase_cost - depr_entry.book_value
          }
        end
      end
      cache_object('depreciation_table', table)
    end
    return table
  end

  # This would normally run super, but it gets added to Asset.  Since there are no TransAM classes
  # above it, it just returns its own UPDATE_METHODS
  def update_methods
    a = []
    a << super
    [:update_book_value].each do |method|
      a << method
    end
    a.flatten
  end

  # Forces an update of an assets book value. This performs an update on the record
  def update_book_value(save_asset = true, policy = nil)

    # can't do this if it is a new record as none of the IDs would be set
    unless new_record?
      update_asset_book_value(save_asset, policy)
    end
  end

  protected

    # updates the book value of an asset
    def update_asset_book_value(save_asset = true, policy = nil)
      Rails.logger.info "Updating book value for asset = #{object_key}"

      # Make sure we are working with a concrete asset class
      asset = is_typed? ? self : Asset.get_typed_asset(self)

      begin


        if asset.depreciable
          if asset.depreciation_entries.count == 0
            asset.depreciation_entries.create!(description: 'Initial Value', book_value: asset.depreciation_purchase_cost, event_date: asset.depreciation_start_date)
          end

          depr_start = asset.current_depreciation_date || asset.depreciation_start_date
          depr_current = asset.policy_analyzer.get_current_depreciation_date
          asset_policy = asset.policy

          # see what algorithm we are using to calculate the book value
          class_name = asset.policy_analyzer.get_depreciation_calculation_type.class_name

          while depr_start <= depr_current
            asset.current_depreciation_date = asset_policy.depreciation_date(depr_start)
            book_value = calculate(asset, class_name)
            asset.book_value = book_value.to_i

            if asset.depreciation_entries.where(description: 'Annual Adjustment', event_date: asset.current_depreciation_date).count == 0
              depr_entry = asset.depreciation_entries.create!(description: 'Annual Adjustment', book_value: asset.book_value, event_date: asset.current_depreciation_date)

              gl_mapping = GeneralLedgerMapping.find_by(organization_id: asset.organization_id, asset_subtype_id: asset.asset_subtype_id)
              if gl_mapping.present? # check whether this app records GLAs at all
                if depr_entry.event_date - 1.year < asset.depreciation_start_date
                  depr_amount = asset.depreciation_entries.find_by(description: 'Initial Value', event_date: asset.depreciation_start_date).book_value - depr_entry.book_value
                else
                  depr_amount = asset.depreciation_entries.find_by(description: 'Annual Adjustment', event_date: depr_entry.event_date - 1.year).book_value - depr_entry.book_value
                end
                gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: asset.current_depreciation_date, description: "Accumulated Depr #{asset.asset_path}", amount: -depr_amount)

                gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: asset.current_depreciation_date, description: "Depr Expense #{asset.asset_path}", amount: depr_amount)
              end
            end

            depr_start = depr_start + 1.year
          end

        else
          asset.book_value = asset.depreciation_purchase_cost

          #update current depreciation date
          asset.current_depreciation_date = asset.policy_analyzer.get_current_depreciation_date
        end

        # save changes to this asset
        asset.save(:validate => false) if save_asset
      rescue Exception => e
        Rails.logger.warn e.message
      end
    end

    # Set resonable defaults for a new asset
    def set_depreciation_defaults
      self.in_service_date ||= self.purchase_date
      self.depreciation_start_date ||= self.in_service_date
      self.depreciation_useful_life ||= self.expected_useful_life
      self.depreciation_purchase_cost ||= self.purchase_cost
      self.book_value ||= self.depreciation_purchase_cost.to_i
      self.salvage_value ||= 0
      self.depreciable = self.depreciable.nil? ? true : self.depreciable

      return true # always return true so can continue to validations

    end


    def clear_depreciation_cache
      # clear cache for other cached depreciation objects that are not attributes
      # hard-coded temporarily
      delete_cached_object('depreciation_table')
    end


    #------------------------------------------------------------------------------
    #
    # Private Methods
    #
    #------------------------------------------------------------------------------
    private

end
