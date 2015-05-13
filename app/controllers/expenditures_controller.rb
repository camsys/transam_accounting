class ExpendituresController < OrganizationAwareController

  # Include the fiscal year mixin
  include FiscalYear

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Expenditures", :expenditures_path

  before_action :set_expenditure, only: [:show, :edit, :update, :destroy]
  before_action :reformat_date_field, only: [:create, :update]

  # Protect the controller
  authorize_resource

  # Session Variables
  INDEX_KEY_LIST_VAR        = "expenditures_list_cache_var"

  # GET /expenditures
  def index

    # get range of fiscal years of all expenditures
    min_date = Expenditure.minimum(:expense_date)
    @fiscal_years = get_fiscal_years(min_date)

    # Start to set up the query
    conditions  = []
    values      = []

    # Limit to the org
    conditions << 'organization_id = ?'
    values << @organization.id

    @general_ledger_account_id = params[:general_ledger_account_id]
    unless @general_ledger_account_id.blank?
      @general_ledger_account_id = @general_ledger_account_id.to_i
      conditions << 'general_ledger_account_id = ?'
      values << @general_ledger_account_id
    end

    @expense_type_id = params[:type]
    unless @expense_type_id.blank?
      @expense_type_id = @expense_type_id.to_i
      conditions << 'expense_type_id = ?'
      values << @expense_type_id

      expense_type = ExpenseType.find(@expense_type_id)
      add_breadcrumb expense_type, expenditures_path(:type => expense_type)
    end

    @vendor_id = params[:vendor_id]
    unless @vendor_id.blank?
      @vendor_id = @vendor_id.to_i
      conditions << 'vendor_id = ?'
      values << @vendor_id
    end

    @fiscal_year = params[:fiscal_year]
    unless @fiscal_year.blank?
      @fiscal_year = @fiscal_year.to_i

      date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{@fiscal_year}"
      start_date = Date.strptime(date_str, "%m-%d-%Y")
      end_date = start_date + 1.year

      conditions << 'expense_date >= ?'
      values << start_date
      conditions << 'expense_date < ?'
      values << end_date

    end

    @expenditures = Expenditure.where(conditions.join(' AND '), *values)

    # cache the expenditure ids in case we need them later
    cache_list(@expenditures, INDEX_KEY_LIST_VAR)

  end

  # GET /expenditures/1
  def show

    add_breadcrumb @expenditure.expense_type, expenditures_path(:type => @expenditure.expense_type)
    add_breadcrumb @expenditure

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@expenditure, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : expenditure_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : expenditure_path(@next_record_key)

  end

  # GET /expenditures/new
  def new
    @expenditure = Expenditure.new

    add_breadcrumb "New"

  end

  # GET /expenditures/1/edit
  def edit
    add_breadcrumb @expenditure.expense_type, expenditures_path(:type => @expenditure.expense_type)
    add_breadcrumb @expenditure, expenditure_path(@expenditure)
    add_breadcrumb 'Update', edit_expenditure_path(@expenditure)
  end

  # POST /expenditures
  def create

    @expenditure = Expenditure.new(expenditure_params)
    @expenditure.organization = @organization

    add_breadcrumb "New"

    # If we have an asset to add we need to return to the asset page
    # not the expenditure page
    unless params[:asset_key].nil?
      raw_asset = Asset.find_by_object_key(params[:asset_key])
      @asset = Asset.get_typed_asset(raw_asset)
      @expenditure.assets << @asset
    end

    if @expenditure.save
      if @asset.present?
        redirect_to inventory_url(@asset), notice: 'Expenditure was successfully created.'
      else
        redirect_to @expenditure, notice: 'Expenditure was successfully created.'
      end
    else
      render :new
    end
  end

  # PATCH/PUT /expenditures/1
  def update

    add_breadcrumb @expenditure.expense_type, expenditures_path(:type => @expenditure.expense_type)
    add_breadcrumb @expenditure, expenditure_path(@expenditure)
    add_breadcrumb 'Update'

    if @expenditure.update(expenditure_params)
      redirect_to @expenditure, notice: 'Expenditure was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /expenditures/1
  def destroy
    @expenditure.destroy
    redirect_to expenditures_url, notice: 'Expenditure was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expenditure
    @expenditure = Expenditure.find_by(:object_key => params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def expenditure_params
    params.require(:expenditure).permit(Expenditure.allowable_params)
  end

  def reformat_date_field
    date_str = params[:expenditure][:expense_date]
    form_date = Date.strptime(date_str, '%m-%d-%Y')
    params[:expenditure][:expense_date] = form_date.strftime('%Y-%m-%d')
  end

end
