class FundingTemplatesController < OrganizationAwareController

  authorize_resource :except => :find_match_required_from_funding_source_id

  add_breadcrumb "Home", :root_path

  before_action :set_funding_template, only: [:show, :edit, :update, :destroy]
  before_action :check_filter,      :only => [:index, :show, :new, :edit]

  INDEX_KEY_LIST_VAR    = "funding_template_key_list_cache_var"

  # GET /funding_templates
  def index

    add_breadcrumb 'Funding Programs', funding_sources_path
    add_breadcrumb 'Templates', funding_templates_path


    # Start to set up the query
    conditions  = []
    values      = []

    @funding_source_id = params[:funding_source_id]
    unless @funding_source_id.blank?
      @funding_source_id = @funding_source_id.to_i
      conditions << 'funding_source_id = ?'
      values << @funding_source_id

      program = FundingSource.find_by(id: @funding_source_id)
      add_breadcrumb program.to_s, funding_source_path(program)
    end

    @show_active_only = params[:show_active_only]
    if @show_active_only
      conditions << 'funding_source_id IN (?)'
      values << FundingSource.active.ids
    end

    #puts conditions.inspect
    #puts values.inspect
    @funding_templates = FundingTemplate.where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@funding_templates, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @funding_templates }
    end

    @funding_templates = FundingTemplate.all
  end

  # GET /funding_templates/1
  def show

    add_breadcrumb @funding_template.funding_source.to_s, funding_source_path(@funding_template.funding_source)
    add_breadcrumb @funding_template.to_s, funding_template_path(@funding_template)

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@funding_template, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : funding_template_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : funding_template_path(@next_record_key)

  end

  # GET /funding_templates/new
  def new

    add_breadcrumb 'Funding Programs', funding_sources_path
    add_breadcrumb 'Templates', funding_templates_path
    add_breadcrumb 'New', new_funding_template_path

    @funding_template = FundingTemplate.new(:funding_source_id => params[:funding_source_id])

    if @funding_template.funding_source.present?
      @funding_template.match_required = @funding_template.funding_source.match_required

      add_breadcrumb @funding_template.funding_source.to_s, funding_source_path(@funding_template.funding_source)
      add_breadcrumb "#{@funding_template.funding_source} Templates", funding_templates_path(:funding_source_id => params[:funding_source_id])
    else
      add_breadcrumb 'Templates', funding_templates_path
    end
    add_breadcrumb 'New', new_funding_template_path

  end

  # GET /funding_templates/1/edit
  def edit
    add_breadcrumb @funding_template.funding_source.to_s, funding_source_path(@funding_template.funding_source)
    add_breadcrumb @funding_template.to_s, funding_template_path(@funding_template)
    add_breadcrumb 'Update', funding_template_path(@funding_template)
  end

  # POST /funding_templates
  def create
    @funding_template = FundingTemplate.new(funding_template_params.except(:organization_ids))

    if params[:query].to_i > 0
      @funding_template.query_string = QueryParam.find(params[:query].to_i).try(:query_string)
    else
      @funding_template.query_string = nil

      org_list = funding_template_params[:organization_ids].split(',').uniq
      org_list.each do |id|
        @funding_template.organizations << Organization.find(id)
      end
    end

    if @funding_template.save

      redirect_to @funding_template, notice: 'Funding template was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /funding_templates/1
  def update
    if @funding_template.update(funding_template_params.except(:organization_ids))

      if params[:query].to_i > 0
        @funding_template.query_string = QueryParam.find(params[:query].to_i).try(:query_string)

        # clear the existing list of organizations
        @funding_template.organizations.clear
      else
        @funding_template.query_string = nil

        # clear the existing list of organizations
        @funding_template.organizations.clear
        # Add the (possibly) new organizations into the object
        org_list = funding_template_params[:organization_ids].split(',')
        org_list.each do |id|
          @funding_template.organizations << Organization.find(id)
        end
      end

      @funding_template.save

      redirect_to @funding_template, notice: 'Funding template was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /funding_templates/1
  def destroy
    funding_source = @funding_template.funding_source
    @funding_template.destroy
    redirect_to funding_source_path(funding_source), notice: 'Template was successfully destroyed.'
  end

  def find_match_required_from_funding_source_id
    funding_source_id = params[:funding_source_id]
    result = FundingSource.find_by(id: funding_source_id).match_required

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  protected

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_funding_template
      @funding_template = FundingTemplate.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def funding_template_params
      params.require(:funding_template).permit(FundingTemplate.allowable_params)
    end
end
