class GeneralLedgerAccountsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Chart of Accounts", :general_ledger_accounts_path

  # Set the @chart_of_accounts variable
  before_filter :get_chart_of_accounts
  # Set the @ledger_account variable
  before_filter :get_ledger_account, :only => [:show, :edit, :update, :destroy]

  # Protect the controller
  authorize_resource

  # Session Variables
  INDEX_KEY_LIST_VAR        = "general_ledger_accounts_list_cache_var"

  def index

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

    if @chart_of_accounts
      @ledger_accounts = @chart_of_accounts.general_ledger_accounts.where(conditions.join(' AND '), *values).order(:name)
    else
      Rails.logger.warn "No chart of accounts found for org #{@organization.short_name}"
      @ledger_accounts = []
    end
    # cache the set of accounts ids in case we need them later
    cache_list(@ledger_accounts, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ledger_accounts }
    end
  end

  def show

    add_breadcrumb @ledger_account.general_ledger_account_type, general_ledger_accounts_path(:type => @ledger_account.general_ledger_account_type)
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

    add_breadcrumb "New", new_general_ledger_account_path

    @ledger_account = GeneralLedgerAccount.new

  end

  # GET /general_ledger_accounts/1/edit
  def edit

    add_breadcrumb @ledger_account.name, general_ledger_account_path(@ledger_account)
    add_breadcrumb "Update"

  end

  # POST /general_ledger_accounts
  # POST /general_ledger_accounts.json
  def create

    add_breadcrumb "New", new_general_ledger_account_path

    @ledger_account = GeneralLedgerAccount.new(form_params)
    @ledger_account.chart_of_account = @chart_of_accounts

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

    add_breadcrumb @ledger_account.name, general_ledger_account_path(@ledger_account)
    add_breadcrumb "Update"

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
    if @ledger_account.assets.count == 0 && @ledger_account.expenditures.count == 0
      @ledger_account.destroy
      redirect_to general_ledger_accounts_url, notice: 'General ledger account was successfully destroyed.'
    else
      redirect_to @ledger_account, notice: 'General ledger account cannot be destroyed as there are assets and expenditures associated with it.'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:general_ledger_account).permit(GeneralLedgerAccount.allowable_params)
  end

  def get_chart_of_accounts
    @chart_of_accounts = @organization.chart_of_accounts
  end

  def get_ledger_account
    # See if it is our chart of accounts
    if @chart_of_accounts && params[:id].present?
      @ledger_account = @chart_of_accounts.general_ledger_accounts.find_by_object_key(params[:id])
    end
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @ledger_account.nil?
      if GeneralLedgerAccount.find_by(object_key: params[:id], organization_id: current_user.user_organization_filters.system_filters.first.get_organizations.map{|x| x.id}).nil?
        redirect_to '/404'
      else
        notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
        redirect_to general_ledger_accounts_path
      end
      return
    end

  end

end
