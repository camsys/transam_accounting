class FundingSourcesController < OrganizationAwareController

  # Include the fiscal year mixin
  include FiscalYear

  authorize_resource :except => :details

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Funding Programs", :funding_sources_path

  before_filter :check_for_cancel,        :only => [:create, :update]
  before_action :set_funding_source,      :only => [:show, :edit, :update, :destroy]

  INDEX_KEY_LIST_VAR    = "funding_source_key_list_cache_var"

  # GET /funding_sources
  # GET /funding_sources.json
  def index

     # Start to set up the query
    conditions  = []
    values      = []

    @funding_source_type_id = params[:funding_source_type_id]
    unless @funding_source_type_id.blank?
      @funding_source_type_id = @funding_source_type_id.to_i
      conditions << 'funding_source_type_id = ?'
      values << @funding_source_type_id
    end

    @show_active_only = params[:show_active_only]

    #puts conditions.inspect
    #puts values.inspect
    @funding_sources = @show_active_only ? FundingSource.active.includes(:funding_source_type).where(conditions.join(' AND '), *values) : FundingSource.includes(:funding_source_type).where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@funding_sources, INDEX_KEY_LIST_VAR)

    if @funding_source_type_id.blank?
      add_breadcrumb "All"
    else
      add_breadcrumb FundingSourceType.find(@funding_source_type_id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @funding_sources }
    end

  end

  # returns details for an funding source as a JSON string
  def details

    if params[:funding_line_item_id]
      line_item = FundingLineItem.find(params[:funding_line_item_id])
      @funding_source = line_item.funding_source
    elsif params[:funding_source_id]
      @funding_source = FundingSource.find(params[:funding_source_id])
    end

    respond_to do |format|
      format.js
      format.json { render :json => @funding_source.to_json }
    end

  end

  # GET /funding_sources/1
  # GET /funding_sources/1.json
  def show

    add_breadcrumb @funding_source.name, funding_source_path(@funding_source)

    # Set the funding line items
    @grants = @funding_source.grants.where('organization_id = ?', @organization.id).order('fy_year')

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@funding_source, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : funding_source_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : funding_source_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @funding_source }
    end

  end

  # GET /funding_sources/new
  def new

    add_breadcrumb "New", new_funding_source_path

    @funding_source = FundingSource.new

  end

  # GET /funding_sources/1/edit
  def edit

    add_breadcrumb @funding_source.name, funding_source_path(@funding_source)
    add_breadcrumb "Update"

  end

  # POST /funding_sources
  # POST /funding_sources.json
  def create

    @funding_source = FundingSource.new(form_params)
    @funding_source.creator = current_user
    @funding_source.updator = current_user

    respond_to do |format|
      if @funding_source.save
        notify_user(:notice, "The funding program was successfully saved.")
        format.html { redirect_to funding_source_url(@funding_source) }
        format.json { render action: 'show', status: :created, location: @funding_source }
      else
        format.html { render action: 'new' }
        format.json { render json: @funding_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /funding_sources/1
  # PATCH/PUT /funding_sources/1.json
  def update

    @funding_source.updator = current_user

    respond_to do |format|
      if @funding_source.update(form_params)
        notify_user(:notice, "The funding program was successfully updated.")
        format.html { redirect_to funding_source_url(@funding_source) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @funding_source.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /funding_sources/1
  # DELETE /funding_sources/1.json
  def destroy
    @funding_source.destroy
    notify_user(:notice, "The funding program was successfully removed.")
    respond_to do |format|
      format.html { redirect_to funding_sources_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_funding_source
      @funding_source = FundingSource.find_by_object_key(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def form_params
      params.require(:funding_source).permit(FundingSource.allowable_params)
    end

  def check_for_cancel
    unless params[:cancel].blank?
      # get the funding source, if one was being edited
      if params[:id]
        redirect_to(funding_source_url(@funding_source))
      else
        redirect_to(funding_sources_url)
      end
    end
  end

end
