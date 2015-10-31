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

    add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
    add_breadcrumb "Update depreciation data"

    @proxy = AssetDepreciableProxy.new
    @proxy.set_defaults(@asset)

  end

  def update_depreciation
    proxy = AssetDepreciableProxy.new(params[:asset_depreciable_proxy])
    base_asset = Asset.find_by_object_key(proxy.object_key)

    # Make sure we are working with a full-typed asset
    asset = Asset.get_typed_asset(base_asset)

    # reformat date
    asset.depreciation_start_date = reformat_date(proxy.depreciation_start_date) if proxy.depreciation_start_date

    asset.depreciable = proxy.depreciable
    asset.salvage_value = proxy.salvage_value if proxy.salvage_value

    asset.updator = current_user

    if asset.save
      notify_user(:notice, "Asset #{asset.name} was successfully updated.")
    end

    redirect_to inventory_path(asset)
  end

  private


end
