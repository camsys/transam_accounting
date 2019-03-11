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

  def get_general_ledger_account
    rule = PolicyAssetSubtypeRule.find_by(policy_id: Policy.find_by(organization_id: params[:organization_id]).id, asset_subtype_id: params[:asset_subtype_id], fuel_type_id: params[:fuel_type_id]).try(:general_ledger_account_id)

    respond_to do |format|
      format.json { render :json => rule.to_json }
    end
  end

  def get_book_value_on_date
    get_asset

    book_val = @asset.depreciation_entries.where('event_date <= ?', reformat_date(params[:on_date])).sum(:book_value)

    respond_to do |format|
      format.json { render :json => book_val.to_json }
    end
  end

  def get_depreciation_months_left
    get_asset
    months_left = @asset.depreciation_months_left(Date.strptime(params[:on_date], '%m/%d/%Y'))

    respond_to do |format|
      format.json { render :json => months_left.to_json }
    end
  end

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
    base_asset = Rails.application.config.asset_base_class_name.constantize.find_by_object_key(proxy.object_key)

    # Make sure we are working with a full-typed asset
    asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(base_asset)

    asset.depreciable = proxy.depreciable
    asset.depreciation_start_date = reformat_date(proxy.depreciation_start_date) if proxy.depreciation_start_date # reformat date
    asset.depreciation_useful_life = proxy.depreciation_useful_life
    asset.depreciation_purchase_cost = proxy.depreciation_purchase_cost
    asset.salvage_value = proxy.salvage_value if proxy.salvage_value

    asset.update_asset_book_value

    if asset.save

      #Delayed::Job.enqueue AssetUpdateJob.new(asset.object_key), :priority => 0

      notify_user(:notice, "Asset #{asset} was successfully updated.")
    end

    redirect_to inventory_path(asset)
  end

  private


end
