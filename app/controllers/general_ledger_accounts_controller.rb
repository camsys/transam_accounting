class GeneralLedgerAccountsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Chart of Accounts", :general_ledger_accounts_path

  # Set the @chart_of_accounts variable
  before_filter :get_chart_of_accounts
  # Set the @ledger_account variable
  before_filter :get_ledger_account, :except => [:index]

  # Session Variables
  INDEX_KEY_LIST_VAR        = "general_ledger_accounts_list_cache_var"

  def index

    @ledger_accounts = @chart_of_accounts.general_ledger_accounts
    # cache the set of accounts ids in case we need them later
    cache_list(@ledger_accounts, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ledger_accounts }
    end
  end

  def show

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

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:notice).permit(GeneralLedgerAccount.allowable_params)
  end

  def get_chart_of_accounts
    @chart_of_accounts = @organization.chart_of_accounts
  end

  def get_ledger_account
    # See if it is our chart of accounts
    @ledger_account = @chart_of_accounts.general_ledger_accounts.find_by_object_key(params[:id]) unless params[:id].nil?
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @ledger_account.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to general_ledger_accounts_url
      return
    end

  end

end
