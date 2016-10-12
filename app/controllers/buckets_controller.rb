class BucketsController < OrganizationAwareController
  # before_action :set_funding_template, only: [:show, :edit, :update, :destroy]

  add_breadcrumb 'Buckets', :buckets_path

  INDEX_KEY_LIST_VAR    = "buckets_key_list_cache_var"

  # GET /buckets
  def index
    add_breadcrumb 'All Buckets', buckets_path

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
    @programs = FundingSource.all
  end

  # GET /buckets/new
  def new
    add_breadcrumb 'New', new_bucket_path

    @programs = FundingSource.all
    @bucket_proxy = BucketProxy.new

  end

  # GET /buckets/1/edit
  def edit
    @programs = FundingSource.all
  end

  # POST /buckets
  def create
    bucket_proxy = BucketProxy.new(bucket_proxy_params)

    bucket = Bucket.new
    bucket.set_values_from_proxy(bucket_proxy)
    bucket.creator = current_user
    bucket.updator = current_user

    unless bucket_proxy.fiscal_year_range_start == bucket_proxy.fiscal_year_range_end
      i = bucket_proxy.fiscal_year_range_start.to_i + 1
      next_year_budget = bucket_proxy.total_amount.to_d
      inflation_percentage = bucket_proxy.inflation_percentage.blank? ? 0 : bucket_proxy.inflation_percentage.to_d/100
      bucket.save

      while i <= bucket_proxy.fiscal_year_range_end.to_i
        next_year = bucket
        next_year.fiscal_year = i
        unless bucket_proxy.inflation_percentage.blank?
          next_year_budget = next_year_budget + (inflation_percentage * next_year_budget)
        end

        next_year.budget_amount = next_year_budget

        i += 1
      end

    else
      bucket.save
    end

    redirect_to buckets_path, notice: 'Bucket was successfully created.'
  end

  # PATCH/PUT /buckets/1
  def update
    @programs = FundingSource.all
  end

  # DELETE /buckets/1
  def destroy
    @programs = FundingSource.all
  end

  def find_organizations_from_template_id

    result = []
    template_id = params[:template_id]
    grantor = Grantor.first
    organizations =  Organization.where("id in (Select organization_id FROM funding_templates_organizations where funding_template_id = #{template_id}) and id <> #{grantor.id}").pluck(:id, :name)
    result = [[-1,'All Agencies For This Template']] + [[grantor.id, grantor.name]] + organizations

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def find_templates_from_program_id
    program_id = params[:program_id]
    result = FundingTemplate.where(funding_source_id: program_id).pluck(:id, :name)

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_bucket
  #   @funding_template = bucket.find_by(object_key: params[:id])
  # end

  # Only allow a trusted parameter "white list" through.
  def bucket_proxy_params
    params.require(:bucket_proxy).permit(BucketProxy.allowable_params)
  end
end
