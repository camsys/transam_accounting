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
    after_create       :set_depreciation_general_ledger_accounts

    #----------------------------------------------------
    # Associations
    #----------------------------------------------------

    has_many :depreciation_entries


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
              :book_value_start => idx > 0 ? asset.depreciation_entries[idx-1].book_value : '',
              :depreciated_expense => idx > 0 ? asset.depreciation_entries[idx-1].book_value - depr_entry.book_value : '',
              :book_value_end => depr_entry.book_value,
              :accumulated_depreciation => asset.purchase_cost - depr_entry.book_value
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
            asset.depreciation_entries.create!(description: 'Initial Value', book_value: asset.purchase_cost, event_date: asset.depreciation_start_date)
          end

          # see what algorithm we are using to calculate the book value
          class_name = asset.policy_analyzer.get_depreciation_calculation_type.class_name
          book_value = calculate(asset, class_name)
          asset.book_value = book_value.to_i

          #update current depreciation date
          asset.current_depreciation_date = asset.policy_analyzer.get_current_depreciation_date

          # if book value and current depreciation has changed, account for it in GLA
          if ( asset.book_value_changed? || asset.current_depreciation_date_changed?) && asset.book_value != asset.purchase_cost
            if asset.depreciation_entries.where(description: 'Annual Adjustment', event_date: asset.current_depreciation_date).count == 0
              asset.depreciation_entries.create!(description: 'Annual Adjustment', book_value: asset.book_value, event_date: asset.current_depreciation_date)
            end
            if asset.general_ledger_accounts.count > 0 # check whether this app records GLAs at all
              depr_amount = self.changes['book_value'][0]-self.changes['book_value'][1]

              amount_not_ledgered = depr_amount # temp variable for tracking rounding errors
              asset.grant_purchases.order(:pcnt_purchase_cost).each_with_index do |grant_purchase, idx|
                unless idx+1 == asset.grant_purchases.count
                  pcnt_depr_amount = (depr_amount * grant_purchase.pcnt_purchase_cost / 100.0).round
                  amount_not_ledgered -= pcnt_depr_amount
                else
                  pcnt_depr_amount = amount_not_ledgered
                end
                asset.general_ledger_accounts.accumulated_depreciation_accounts.find_by(grant_id: grant_purchase.sourceable_id).general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} #{asset.current_depreciation_date}", amount: -pcnt_depr_amount)

                asset.general_ledger_accounts.depreciation_expense_accounts.find_by(grant_id: grant_purchase.sourceable_id).general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} #{asset.current_depreciation_date}", amount: pcnt_depr_amount)
              end

            end
          end
        else
          asset.book_value = asset.purchase_cost

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
      self.book_value ||= self.purchase_cost.to_i
      self.salvage_value ||= 0
      self.depreciable = self.depreciable.nil? ? true : self.depreciable

      return true # always return true so can continue to validations

    end


    def clear_depreciation_cache
      # clear cache for other cached depreciation objects that are not attributes
      # hard-coded temporarily
      delete_cached_object('depreciation_table')
    end

    def set_depreciation_general_ledger_accounts

      if GrantPurchase.sourceable_type == 'Grant' && general_ledger_account_id.present?
        # just add depreciation GLAs for now
        # does not add GLA entries that is done during update_depreciation
        grant_purchases.each do |grant_purchase|
          # accumulated depr
          general_ledger_accounts << organization.general_ledger_accounts.accumulated_depreciation_accounts.find_by(grant_id: grant_purchase.sourceable_id)

          # depr_expense_gla
          general_ledger_accounts << organization.general_ledger_accounts.depreciation_expense_accounts.find_by(grant_id: grant_purchase.sourceable_id)
        end
      end

    end


    #------------------------------------------------------------------------------
    #
    # Private Methods
    #
    #------------------------------------------------------------------------------
    private

end
