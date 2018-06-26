class GeneralLedgerAccountsController < OrganizationAwareController
  include FiscalYearHelper

  add_breadcrumb "Home", :root_path

  # Set the @chart_of_accounts and @ledger_account variable
  before_action :get_ledger_account, :only => [:show, :edit, :update, :destroy]

  # Protect the controller
  authorize_resource

  # Session Variables
  INDEX_KEY_LIST_VAR        = "general_ledger_accounts_list_cache_var"

  def index

    if params[:organization_id].present?
      @organization_id = params[:organization_id].to_i
    end
    if @organization_id.nil? || @organization_list.index(@organization_id).nil?
      @organization_id = @organization_list.first
    end

    @chart_of_accounts = Organization.find_by(id: @organization_id).chart_of_accounts

    if @organization_list.count > 1
      @total_rows = @organization_list.count
      org_idx = @organization_list.index(@organization_id)
      @row_number = org_idx+1
      @prev_record_key = Organization.find_by(id: @organization_list[org_idx-1]).chart_of_accounts.object_key if org_idx > 0
      @next_record_key = Organization.find_by(id: @organization_list[org_idx+1]).chart_of_accounts.object_key if org_idx < @organization_list.count - 1

      @prev_record_path = @prev_record_key.nil? ? "#" : capital_plan_path(@prev_record_key)
      @next_record_path = @next_record_key.nil? ? "#" : capital_plan_path(@next_record_key)
    end

     # Start to set up the query
    conditions  = []
    values      = []

    @account_type_id = params[:type]
    unless @account_type_id.blank?
      @account_type_id = @account_type_id.to_i
      conditions << 'general_ledger_account_type_id = ?'
      values << @account_type_id

      account_type = GeneralLedgerAccountType.find(@account_type_id)
      add_breadcrumb account_type, general_ledger_accounts_path(:type => account_type)

    end

    @account_subtype_id = params[:subtype]
    unless @account_subtype_id.blank?
      @account_subtype_id = @account_subtype_id.to_i
      conditions << 'general_ledger_account_subtype_id = ?'
      values << @account_subtype_id

      account_subtype = GeneralLedgerAccountSubtype.find(@account_subtype_id)
      add_breadcrumb account_subtype, general_ledger_accounts_path(:subtype => account_subtype)

    end

    @ledger_accounts = @chart_of_accounts.general_ledger_accounts.where(conditions.join(' AND '), *values).order(:name)

    add_breadcrumb @chart_of_accounts, general_ledger_accounts_path(organization_id: @chart_of_accounts.organization_id)

    # cache the set of accounts ids in case we need them later
    cache_list(@ledger_accounts, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ledger_accounts }
    end
  end

  def toggle_archive
    coa = ChartOfAccount.find_by(id: params[:chart_of_account_id])

    if coa.present?
      if ArchivedFiscalYear.archive(coa.organization_id, params[:fy_year], true)
        notify_user(:notice, "The #{get_fy_label} was successfully archived/unarchived.")
      else
        notify_user(:alert, "Cannot archive/unarchive #{get_fy_label}.")
      end

      redirect_to general_ledger_accounts_path(organization_id: coa.organization_id)
    else
      redirect_to '/404'
    end
  end

  def show

    add_breadcrumb @chart_of_accounts, general_ledger_accounts_path(organization_id: @chart_of_accounts.organization_id)
    add_breadcrumb @ledger_account

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@ledger_account, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : general_ledger_account_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : general_ledger_account_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render :json => @ledger_account }
    end
  end

  # GET /general_ledger_accounts/new
  def new

    if params[:chart_of_account_id].nil?
      notify_user(:warning, 'Cannot create GLA without a chart of account.')
      redirect_to general_ledger_accounts_path
    else
      @chart_of_accounts = ChartOfAccount.find_by(id: params[:chart_of_account_id])
      add_breadcrumb @chart_of_accounts, general_ledger_accounts_path(organization_id: @chart_of_accounts.organization_id)
      add_breadcrumb "New", new_general_ledger_account_path
      @ledger_account = GeneralLedgerAccount.new
    end

  end

  # GET /general_ledger_accounts/1/edit
  def edit
    add_breadcrumb @chart_of_accounts, general_ledger_accounts_path(organization_id: @chart_of_accounts.organization_id)
    add_breadcrumb @ledger_account
    add_breadcrumb "Update"

  end

  def get_accounts
    case params[:subtype]
      when 'fixed_asset'
        result = GeneralLedgerAccount.fixed_asset_accounts.where(chart_of_account_id: params[:chart_of_account_id])
      when 'depreciation_expense'
        result = GeneralLedgerAccount.depreciation_expense_accounts.where(chart_of_account_id: params[:chart_of_account_id])
      when 'accumulated_depreciation'
        result = GeneralLedgerAccount.accumulated_depreciation_accounts.where(chart_of_account_id: params[:chart_of_account_id])
      when 'disposal'
        result = GeneralLedgerAccount.disposal_accounts.where(chart_of_account_id: params[:chart_of_account_id])
      else
        result = GeneralLedgerAccount.where(chart_of_account_id: params[:chart_of_account_id])
    end

    respond_to do |format|
      format.json { render json: result.map{|x| [x.id, x.coded_name]}.to_json }
    end
  end

  def check_grant_budget
    @grant = Grant.find_by(id: params[:grant_id])
    available = @grant.amount - @grant.grant_budgets.sum(:amount)

    respond_to do |format|
      format.json { render :json => available.to_json }
    end
  end

  # POST /general_ledger_accounts
  # POST /general_ledger_accounts.json
  def create

    @ledger_account = GeneralLedgerAccount.new(form_params)

    respond_to do |format|
      if @ledger_account.save
        notify_user(:notice, "The general ledger account was successfully saved.")

        format.html { redirect_to general_ledger_account_url(@ledger_account) }
        format.json { render action: 'show', status: :created, location: @ledger_account }
      else
        format.html { render action: 'new' }
        format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /general_ledger_accounts/1
  # PATCH/PUT /general_ledger_accounts/1.json
  def update

    respond_to do |format|
      if @ledger_account.update(form_params)
        notify_user(:notice, "The general ledger account was successfully updated.")
        format.html { redirect_to general_ledger_account_url(@ledger_account) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @ledger_account.general_ledger_account_entries.count == 0
      @ledger_account.destroy
      redirect_to general_ledger_accounts_url, notice: 'General ledger account was successfully destroyed.'
    else
      redirect_to @ledger_account, notice: 'General ledger account cannot be destroyed as there are entries in its ledger.'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:general_ledger_account).permit(GeneralLedgerAccount.allowable_params)
  end

  def get_ledger_account
    chart_of_account_ids = ChartOfAccount.where(organization_id: @organization_list).ids
    @ledger_account = GeneralLedgerAccount.find_by(object_key: params[:id], chart_of_account_id: chart_of_account_ids)

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @ledger_account.nil?
      chart_of_account_ids = ChartOfAccount.where(organization_id: current_user.user_organization_filters.system_filters.first.get_organizations.map{|x| x.id}).ids
      if GeneralLedgerAccount.find_by(object_key: params[:id], chart_of_account_id: chart_of_account_ids).nil?
        redirect_to '/404'
      else
        notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
        redirect_to general_ledger_accounts_path
      end
      return
    else
      @chart_of_accounts = @ledger_account.chart_of_account
    end

  end

end
