class GrantsController < OrganizationAwareController

  # Include the fiscal year mixin
  include FiscalYear

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Grants", :grants_path

  before_action :set_grant, :only => [:show, :edit, :update, :destroy, :summary_info]

  INDEX_KEY_LIST_VAR    = "grants_key_list_cache_var"

  def index

    @fiscal_years = fiscal_year_range

     # Start to set up the query
    conditions  = []
    values      = []

    conditions << 'organization_id IN (?)'
    values << @organization_list

    @sourceable_id = params[:sourceable_id]
    unless @sourceable_id.blank?
      @sourceable_id = @sourceable_id.to_i
      conditions << 'sourceable_id = ?'
      values << @sourceable_id
    end

    @fiscal_year = params[:fiscal_year]
    unless @fiscal_year.blank?
      @fiscal_year = @fiscal_year.to_i
      conditions << 'fy_year = ?'
      values << @fiscal_year
    end

    # TODO fix for sourceable
    @grants = Grant.where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@grants, INDEX_KEY_LIST_VAR)

    if @sourceable_id.blank?
      add_breadcrumb "All"
    else
      add_breadcrumb Grant::SOURCEABLE_TYPE.constantize.find_by(id: @sourceable_id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @grants }
    end

  end

  def summary_info

    respond_to do |format|
      format.js # summary_info.js.haml
      format.json { render :json => @grant }
    end

  end

  # GET /grants/1
  # GET /grants/1.json
  def show

    add_breadcrumb @grant.sourceable, eval(@grant.sourceable_path)
    add_breadcrumb @grant.to_s, grant_path(@grant)

    @assets = @grant.assets.where('organization_id in (?)', @organization_list)

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@grant, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : grant_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : grant_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @grant }
    end

  end

  # GET /grant/new
  def new

    add_breadcrumb "New", new_grant_path

    # get fiscal years up to planning year + 3 years
    @fiscal_years = fiscal_year_range(4)

    @grant = Grant.new(:sourceable_id => params[:sourceable_id])

  end

  # GET /grants/1/edit
  def edit

    add_breadcrumb @grant.sourceable, eval(@grant.sourceable_path)
    add_breadcrumb @grant.to_s, grant_path(@grant)
    add_breadcrumb "Update"

    # get fiscal years up to planning year + 3 years
    @fiscal_years = fiscal_year_range(4)

  end

  # POST /grants
  # POST /grants.json
  def create

    @grant = Grant.new(grant_params.except(:sourceable_id))
    @grant.sourceable = Grant::SOURCEABLE_TYPE.constantize.find_by(id: params[:grant][:sourceable_id])
    @grant.organization_id = @organization_list.first if @grant.organization_id.nil?

    respond_to do |format|
      if @grant.save
        notify_user(:notice, "The Grant was successfully saved.")
        format.html { redirect_to grant_url(@grant) }
        format.json { render action: 'show', status: :created, location: @grant }
      else
        format.html { render action: 'new' }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grants/1
  # PATCH/PUT /grants/1.json
  def update

    # get fiscal years up to planning year + 3 years
    @fiscal_years = fiscal_year_range(4)

    respond_to do |format|
      if @grant.update(grant_params)
        notify_user(:notice, "The Gratn was successfully updated.")
        format.html { redirect_to grant_url(@grant) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grant/1
  # DELETE /grant/1.json
  def destroy
    name = @grant.to_s
    @grant.destroy
    notify_user(:notice, "Grant #{name} was successfully removed.")
    respond_to do |format|
      format.html { redirect_to grants_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find_by_object_key(params[:id])
    end

    def fiscal_year_range(num_forecasting_years=nil)
      # get range of fiscal years of all grants. Default to current fiscal
      # years if there are no grants available
      min_fy = Grant.where(:organization => @organization).minimum(:fy_year)

      if min_fy.nil?
        get_fiscal_years
      else
        date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{min_fy}"
        start_of_min_fy = Date.strptime(date_str, "%m-%d-%Y")
        get_fiscal_years(start_of_min_fy,num_forecasting_years)
      end
    end

    def grant_params
      params.require(:grant).permit(Grant.allowable_params)
    end

end
