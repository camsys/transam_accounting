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

    if params[:template_id].present?
      @organizations =  Organization.where("id in (Select organization_id FROM funding_templates_organizations where funding_template_id = #{template_id}}").pluck(:name, :id)
    else
      @organizations =  Organization.all.pluck(:name, :id)
    end
    if params[:agency_id].present?
      @searched_agency_id =  params[:agency_id]
    end
    if params[:fiscal_year].present?
      @searched_fiscal_year =  params[:fiscal_year]
    end
    if params[:funds_available].present?
      @show_funds_available_only =  params[:funds_available]
    end

    unless @searched_agency_id.blank?
      agency_filter_id = @searched_agency_id.to_i
      conditions << 'owner_id = ?'
      values << agency_filter_id
    end

    unless @searched_fiscal_year.blank?
      fiscal_year_filter = @searched_fiscal_year.to_i
      conditions << 'fiscal_year = ?'
      values << fiscal_year_filter
    end

    if @show_funds_available_only
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
  end

  # GET /buckets/1
  def show





  end

  # GET /buckets/new
  def new
    add_breadcrumb 'New', new_bucket_path

    @programs = FundingSource.all
    @bucket_proxy = BucketProxy.new
    @bucket_proxy.set_defaults
  end

  # GET /buckets/1/edit
  def edit
    @programs = FundingSource.all
  end

  # POST /buckets
  def create
    bucket_proxy = BucketProxy.new(bucket_proxy_params)

    unless bucket_proxy.owner_id.to_i <= 1
      bucket = new_bucket_from_proxy(bucket_proxy)
      create_single_organization_buckets(bucket, bucket_proxy)
    else
      bucket = new_bucket_from_proxy(bucket_proxy)
      agencies = bucket.funding_template.organizations
      agencies << Grantor.first

      agencies.each { |aa|
        bucket = new_bucket_from_proxy(bucket_proxy, aa.id)
        bucket.budget_amount = params["agency_budget_id_#{aa.id}".parameterize.underscore.to_sym].to_d
        # bucket_proxy inflation percentage could be modified the same way
        create_single_organization_buckets(bucket, bucket_proxy, aa.id, )
      }

    end

    redirect_to buckets_path, notice: 'Bucket was successfully created.'
  end

  def new_bucket_from_proxy(bucket_proxy, agency_id=nil)
    bucket = Bucket.new
    bucket.set_values_from_proxy(bucket_proxy, agency_id)
    bucket.creator = current_user
    bucket.updator = current_user
    bucket
  end

  def create_single_organization_buckets(bucket, bucket_proxy, agency_id=nil)
    unless bucket_proxy.fiscal_year_range_start == bucket_proxy.fiscal_year_range_end
      i = bucket_proxy.fiscal_year_range_start.to_i + 1
      next_year_budget = bucket.budget_amount
      inflation_percentage = bucket_proxy.inflation_percentage.blank? ? 0 : bucket_proxy.inflation_percentage.to_d/100

      bucket.save


      while i <= bucket_proxy.fiscal_year_range_end.to_i
        next_year_bucket = new_bucket_from_proxy(bucket_proxy, agency_id)
        next_year_bucket.fiscal_year = i

        unless bucket_proxy.inflation_percentage.blank?
          next_year_budget = next_year_budget + (inflation_percentage * next_year_budget)
        end
        next_year_bucket.budget_amount = next_year_budget

        next_year_bucket.save

        i += 1
      end

    else
      bucket.save
    end
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
    @bucket_agency_allocations = []

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
