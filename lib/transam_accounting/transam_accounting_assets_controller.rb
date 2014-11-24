module TransamAccounting

  module TransamAccountingAssetsController
    #------------------------------------------------------------------------------
    #
    # Accounting Methods for AssetsController
    #
    # Injects methods and associations for managing depreciable assets into
    # Assets controller
    #
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
    # Instance Methods
    #
    #------------------------------------------------------------------------------

    # form for updating depreciation inputs
    def edit_depreciation
      get_asset

      add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path
      add_breadcrumb @asset.name, inventory_path(@asset)
      add_breadcrumb "Modify Depreciation", edit_depreciation_inventory_path(@asset)

      @proxy = AssetDepreciableProxy.new
      @proxy.set_defaults(@asset)

    end

    def update_depreciation
      proxy = AssetDepreciableProxy.new(params[:asset_depreciable_proxy])
      Rails.logger.debug "PROXPROX"+proxy.inspect
      asset = Asset.find_by_object_key(proxy.object_key)

      # reformat date
      asset.depreciation_start_date = reformat_depreciation_date(proxy.depreciation_start_date) if proxy.depreciation_start_date

      asset.depreciable = proxy.depreciable
      asset.salvage_value = proxy.salvage_value if proxy.salvage_value
      asset.expected_useful_life = proxy.expected_useful_life if proxy.expected_useful_life
      asset.expected_useful_miles = proxy.expected_useful_miles if proxy.expected_useful_miles

      asset.updator = current_user

      asset.save

      redirect_to inventory_path(asset)
    end

    private
      def reformat_depreciation_date(date_str)
        form_date = Date.strptime(date_str, '%m-%d-%Y')
        return form_date.strftime('%Y-%m-%d')
      end

  end
end
