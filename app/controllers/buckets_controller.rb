class BucketsController < OrganizationAwareController
  # before_action :set_funding_template, only: [:show, :edit, :update, :destroy]

  add_breadcrumb 'Buckets', :buckets_path

  INDEX_KEY_LIST_VAR    = "buckets_key_list_cache_var"

  # GET /buckets
  def index
    add_breadcrumb 'All Buckets', funding_templates_path

    # Start to set up the query
    conditions  = []
    values      = []

    @agency_id_filter = params[:agency_id_filter]
    unless @agency_filter_id.blank?
      agency_filter_id = @agency_id_filter.to_i
      conditions << 'owner_id = ?'
      values << agency_filter_id
    end

    @fiscal_year_filter = params[:fiscal_year_filter]
    unless @fiscal_year_filter.blank? || @fiscal_year == 'ALL'
      fiscal_year_filter = @fiscal_year_filter.to_i
      conditions << 'fiscal_year = ?'
      values << fiscal_year_filter
    end

    @funds_available_filter = params[:funds_available_filter]
    if @funds_available_filter
      conditions << 'budget_amount > budget_committed'
    end

    puts conditions.inspect
    puts values.inspect
    @buckets = Bucket.where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@buckets, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @buckets }
    end

    @buckets = Bucket.all
  end

  # GET /buckets/1
  def show

  end

  # GET /buckets/new
  def new
    @programs = FundingSource.all

  end

  # GET /buckets/1/edit
  def edit

  end

  # POST /buckets
  def create

  end

  # PATCH/PUT /buckets/1
  def update

  end

  # DELETE /buckets/1
  def destroy

  end

  def find_organizations_from_template_id(template)
    organizaitons = Grantor.all.pluck(:name, :id)

    organizaitons + Organization.where("id in (Select organization_id FROM funding_templates_organizations where funding_template_id = #{template.id}) and id <> #{Grantor.first.id}").pluck(:id, :name)
  end

  def find_templates_from_program(program)
    FundingTemplate.where(funding_source_id: program.id).pluck(:id, :name)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_bucket
  #   @funding_template = bucket.find_by(object_key: params[:id])
  # end

  # Only allow a trusted parameter "white list" through.
  # def bucket_params
  #   params.require(:bucket).permit(Bucket.allowable_params)
  # end
end
