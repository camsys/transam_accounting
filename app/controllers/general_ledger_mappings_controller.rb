class GeneralLedgerMappingsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  INDEX_KEY_LIST_VAR    = "bond_request_key_list_cache_var"

  before_action :set_general_ledger_mapping, only: [:show, :edit, :update, :destroy]

  # GET /general_ledger_mappings
  def index

    # Start to set up the query
    conditions  = []
    values      = []

    if params[:chart_of_account_id]
      @chart_of_account_id = params[:chart_of_account_id].to_i
      conditions << 'chart_of_account_id = ?'
      values << @chart_of_account_id

      coa = ChartOfAccount.find_by(id: @chart_of_account_id)
      add_breadcrumb coa, general_ledger_accounts_path(organization_id: coa.organization_id)
      add_breadcrumb "GL Mappings", :general_ledger_mappings_path
    end

    if params[:asset_type_filter]
      @asset_type_filter = params[:asset_type_filter]
      conditions << 'asset_subtype_id IN (?)'
      values << AssetSubtype.where(id: @asset_type_filter).ids
    else
      @asset_type_filter = []
    end

    #puts conditions.inspect
    #puts values.inspect
    @general_ledger_mappings = GeneralLedgerMapping.where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@general_ledger_mappings, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @general_ledger_mappings }
    end

  end

  # GET /general_ledger_mappings/1
  def show
  end

  # GET /general_ledger_mappings/new
  def new

    @chart_of_account_id = params[:chart_of_account_id].to_i
    coa = ChartOfAccount.find_by(id: @chart_of_account_id)
    add_breadcrumb coa, general_ledger_accounts_path(organization_id: coa.organization_id)
    add_breadcrumb "GL Mappings", general_ledger_mappings_path(chart_of_account_id: @chart_of_account_id)
    add_breadcrumb "New", new_general_ledger_mapping_path(chart_of_account_id: @chart_of_account_id)

    @general_ledger_mapping = GeneralLedgerMapping.new(chart_of_account_id: @chart_of_account_id)
  end

  # GET /general_ledger_mappings/1/edit
  def edit
    @chart_of_account_id = @general_ledger_mapping.chart_of_account_id
    coa = ChartOfAccount.find_by(id: @chart_of_account_id)
    add_breadcrumb coa, general_ledger_accounts_path(organization_id: coa.organization_id)
    add_breadcrumb "GL Mappings", general_ledger_mappings_path(chart_of_account_id: @chart_of_account_id)
    add_breadcrumb "Update #{@general_ledger_mapping}", edit_general_ledger_mapping_path(@general_ledger_mapping)
  end

  # POST /general_ledger_mappings
  def create
    @general_ledger_mapping = GeneralLedgerMapping.new(general_ledger_mapping_params)

    if @general_ledger_mapping.save
      redirect_to general_ledger_mappings_path(chart_of_account_id: @general_ledger_mapping.chart_of_account_id), notice: 'General ledger mapping was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /general_ledger_mappings/1
  def update
    if @general_ledger_mapping.update(general_ledger_mapping_params)
      redirect_to general_ledger_mappings_path(chart_of_account_id: @general_ledger_mapping.chart_of_account_id), notice: 'General ledger mapping was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /general_ledger_mappings/1
  def destroy
    chart_of_account_id = @general_ledger_mapping.chart_of_account_id
    @general_ledger_mapping.destroy
    redirect_to general_ledger_mappings_path(chart_of_account_id: chart_of_account_id), notice: 'General ledger mapping was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_general_ledger_mapping
      @general_ledger_mapping = GeneralLedgerMapping.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def general_ledger_mapping_params
      params.require(:general_ledger_mapping).permit(GeneralLedgerMapping.allowable_params)
    end
end
