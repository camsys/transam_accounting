class ExpendituresController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Expenditures", :expenditures_path

  before_action :set_expenditure, only: [:show, :edit, :update, :destroy]

  # Session Variables
  INDEX_KEY_LIST_VAR        = "expenditures_list_cache_var"

  # GET /expenditures
  def index

    # Start to set up the query
    conditions  = []
    values      = []

    # Limit to the org
    conditions << 'organization_id = ?'
    values << @organization.id

    @expense_type_id = params[:type]
    unless @expense_type_id.blank?
      @expense_type_id = @expense_type_id.to_i
      conditions << 'expense_type_id = ?'
      values << @expense_type_id

      expense_type = ExpenseType.find(@expense_type_id)
      add_breadcrumb expense_type, expenditures_path(:type => expense_type)

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
  end

  # GET /expenditures/1/edit
  def edit
  end

  # POST /expenditures
  def create
    @expenditure = Expenditure.new(expenditure_params)

    if @expenditure.save
      redirect_to @expenditure, notice: 'Expenditure was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /expenditures/1
  def update
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
end
