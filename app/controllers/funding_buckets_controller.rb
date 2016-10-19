class FundingBucketsController < OrganizationAwareController
  # before_action :set_funding_template, only: [:show, :edit, :update, :destroy]

  add_breadcrumb 'Funding Buckets', :funding_buckets_path

  before_action :check_filter,      :only => [:index, :show, :new, :edit]

  INDEX_KEY_LIST_VAR    = "funding_buckets_key_list_cache_var"

  # GET /buckets
  def index
    authorize! :read, FundingBucket

    add_breadcrumb 'All Buckets', funding_buckets_path

    # Start to set up the query
    conditions  = []
    values      = []

    @should_include_add_bucket = true

    if params[:template_id].present?
      @organizations =  Organization.where("id in (Select organization_id FROM funding_templates_organizations where funding_template_id = #{template_id}}").pluck(:name, :id)
    else
      @organizations =  Organization.where(id: @organization_list).pluck(:name, :id)
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

    conditions << 'active = true'

    @buckets = FundingBucket.where(conditions.join(' AND '), *values)

    # cache the set of object keys in case we need them later
    cache_list(@buckets, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @buckets }
    end
  end

  # GET /buckets/1
  def show
    authorize! :read, FundingBucket




  end

  # GET /buckets/new
  def new
    authorize! :create, FundingBucket

    add_breadcrumb 'New', new_funding_bucket_path

    if @bucket_proxy.present?
      @bucket_proxy = @bucket_proxy
    else
      @bucket_proxy = FundingBucketProxy.new
      @bucket_proxy.set_defaults
    end
    if @programs.present?
      @programs = @programs
    else
      @programs = FundingSource.all
    end
    if @templates.present?
      @templates = @templates
    else
      @templates = []
    end
    if @template_organizations.present?
      @template_organizations = @template_organizations
    else
      @template_organizations = []
    end
  end

  # GET /buckets/confirm
  def confirm
    authorize! :create, FundingBucket

    add_breadcrumb 'New', new_funding_bucket_path

    if @bucket_proxy.present?
      @bucket_proxy = @bucket_proxy
    else
      @bucket_proxy = FundingBucketProxy.new
      @bucket_proxy.set_defaults
    end
    if @programs.present?
      @programs = @programs
    else
      @programs = FundingSource.all
    end
    if @templates.present?
      @templates = @templates
    else
      @templates = []
    end
    if @template_organizations.present?
      @template_organizations = @template_organizations
    else
      @template_organizations = []
    end
  end

  # GET /buckets/1/edit
  def edit
    authorize! :edit, FundingBucket

    @programs = FundingSource.all
  end

  # POST /buckets
  def create
    authorize! :read, FundingBucket

    bucket_proxy = FundingBucketProxy.new(bucket_proxy_params)
    @bucket_proxy = bucket_proxy
    @existing_buckets = FundingBucket.find_existing_buckets_from_proxy(bucket_proxy.template_id, bucket_proxy.fiscal_year_range_start, bucket_proxy.fiscal_year_range_end, bucket_proxy.owner_id)

    if bucket_proxy.create_option == 'Create'
      if @existing_buckets.length > 0 && (bucket_proxy.create_conflict_option.blank?)

        @create_conflict = true
        flash.now[:notice] = "Alert: #{@existing_buckets.length} conflicts found. Please select if you want to update existing buckets, ignore existing buckets, or cancel"
      elsif @existing_buckets.length > 0 && (bucket_proxy.create_conflict_option == 'Cancel')
        redirect_to funding_buckets_path, notice: 'Bucket creation cancelled because of conflict.'
      elsif @existing_buckets.length > 0
        create_new_buckets(bucket_proxy, @existing_buckets, bucket_proxy.create_conflict_option)
        redirect_to funding_buckets_path, notice: 'Buckets successfully created.'
      else
        create_new_buckets(bucket_proxy)
        redirect_to funding_buckets_path, notice: 'Buckets successfully created.'
      end
    end

    if bucket_proxy.create_option == 'Update'
      expected_buckets = find_expected_bucket_count(bucket_proxy)

      if expected_buckets > @existing_buckets.length && bucket_proxy.update_conflict_option.blank?
        @update_conflict = true

        flash.now[:notice] = "Some buckets to be updated have not been created. Please select if you want to create new buckets, ignore missing buckets, or cancel"
      elsif expected_buckets > @existing_buckets.length && bucket_proxy.update_conflict_option  == 'Cancel'
        redirect_to funding_buckets_path, notice: 'Bucket update cancelled because of conflict.'
      else
        update_buckets(bucket_proxy, @existing_buckets, bucket_proxy.update_conflict_option)
        redirect_to funding_buckets_path, notice: 'Buckets updated.'
      end
    end

    if bucket_proxy.create_option == 'Delete'
      @existing_buckets.each { |eb|
        eb.active = false
        eb.updator = current_user
        eb.save
      }
      redirect_to funding_buckets_path, notice: "#{@existing_buckets.length} buckets deleted."
    end
  end

  def create_new_buckets(bucket_proxy, existing_buckets=nil, create_conflict_option=nil)

    unless bucket_proxy.owner_id.to_i <= 0
      bucket = new_bucket_from_proxy(bucket_proxy)
      create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, create_conflict_option, 'Create')
    else
      bucket = new_bucket_from_proxy(bucket_proxy)
      agencies = bucket.funding_template.organizations
      agencies << Grantor.first

      agencies.each { |aa|
        bucket = new_bucket_from_proxy(bucket_proxy, aa.id)
        bucket.budget_amount = params["agency_budget_id_#{aa.id}".parameterize.underscore.to_sym].to_d
        # bucket_proxy inflation percentage could be modified the same way
        create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, create_conflict_option, 'Create', aa.id,)
      }

    end
  end

  def update_buckets(bucket_proxy, existing_buckets=nil, update_conflict_option=nil )

    unless bucket_proxy.owner_id.to_i <= 0
      bucket = new_bucket_from_proxy(bucket_proxy)
      create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, 'Update',  update_conflict_option)
    else
      bucket = new_bucket_from_proxy(bucket_proxy)
      agencies = bucket.funding_template.organizations
      agencies << Grantor.first

      agencies.each { |aa|
        bucket = new_bucket_from_proxy(bucket_proxy, aa.id)
        bucket.budget_amount = params["agency_budget_id_#{aa.id}".parameterize.underscore.to_sym].to_d
        # bucket_proxy inflation percentage could be modified the same way
        create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, 'Update', update_conflict_option, aa.id,)
      }

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

    template = FundingTemplate.find_by(id: template_id)
    if template.owner == FundingSourceType.find_by(name: 'State')
      grantors = Grantor.where(id: @organization_list)
      grantors.each { |g|
        result << [g.id, g.name]
      }

    else
      grantor = Grantor.first
      organizations =  Organization.where("id in (Select organization_id FROM funding_templates_organizations where funding_template_id = #{template_id}) and id <> #{grantor.id}").pluck(:id, :name)
      result = [[-1,'All Agencies For This Template']] + [[grantor.id, grantor.name]] + organizations
    end

    @template_organizations = result
    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def find_templates_from_program_id
    program_id = params[:program_id]
    result = FundingTemplate.where(funding_source_id: program_id).pluck(:id, :name)
    @templates = result

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  protected

  def check_filter
    if current_user.user_organization_filter != current_user.user_organization_filters.system_filters.first || current_user.user_organization_filters.system_filters.first.get_organizations.count != @organization_list.count
      set_current_user_organization_filter_(current_user, current_user.user_organization_filters.system_filters.first)
      notify_user(:filter_warning, "Filter reset to enter funding.")

      get_organization_selections
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  # Only allow a trusted parameter "white list" through.
  def bucket_proxy_params
    params.require(:funding_bucket_proxy).permit(FundingBucketProxy.allowable_params)
  end

  def new_bucket_from_proxy(bucket_proxy, agency_id=nil)
    bucket = FundingBucket.new
    bucket.set_values_from_proxy(bucket_proxy, agency_id)
    bucket.creator = current_user
    bucket.updator = current_user
    bucket
  end

  def create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, create_conflict_option, update_conflict_option, agency_id=nil)

    unless bucket_proxy.fiscal_year_range_start == bucket_proxy.fiscal_year_range_end
      i = bucket_proxy.fiscal_year_range_start.to_i + 1
      next_year_budget = bucket.budget_amount
      inflation_percentage = bucket_proxy.inflation_percentage.blank? ? 0 : bucket_proxy.inflation_percentage.to_d/100

      existing_bucket = bucket_exists(existing_buckets, bucket)
      if !existing_bucket.nil? && create_conflict_option == 'Ignore'
        #   DO NOTHING
      elsif !existing_bucket.nil? && create_conflict_option == 'Update'
        existing_bucket.budget_amount = bucket.budget_amount
        existing_bucket.updator = current_user
        existing_bucket.save
      elsif update_conflict_option == 'Create'
        bucket.save
      end

      while i <= bucket_proxy.fiscal_year_range_end.to_i
        next_year_bucket = new_bucket_from_proxy(bucket_proxy, agency_id)
        next_year_bucket.fiscal_year = i

        unless bucket_proxy.inflation_percentage.blank?
          next_year_budget = next_year_budget + (inflation_percentage * next_year_budget)
        end
        next_year_bucket.budget_amount = next_year_budget


        existing_bucket = bucket_exists(existing_buckets, next_year_bucket)
        if !existing_bucket.nil? && create_conflict_option == 'Ignore'
          #   DO NOTHING
        elsif !existing_bucket.nil? && create_conflict_option == 'Update'
          existing_bucket.budget_amount = next_year_bucket.budget_amount
          existing_bucket.updator = current_user
          existing_bucket.save
        elsif update_conflict_option == 'Create'
          next_year_bucket.save
        end

        i += 1
      end

    else
      existing_bucket = bucket_exists(existing_buckets, bucket)
      if !existing_bucket.nil? && create_conflict_option == 'Ignore'
        #   DO NOTHING
      elsif !existing_bucket.nil? && create_conflict_option == 'Update'
        existing_bucket.budget_amount = bucket.budget_amount
        existing_bucket.bucket.updator = current_user
        existing_bucket.save
      else
        bucket.save
      end
    end
  end

  def bucket_exists existing_buckets, bucket
    unless existing_buckets.nil?
      buckets = existing_buckets.find {|eb|
        eb.funding_template == bucket.funding_template && eb.fiscal_year == bucket.fiscal_year && eb.owner == bucket.owner
      }
      return buckets
    end

    return nil
  end

  def find_expected_bucket_count bucket_proxy

    number_of_organizations = 1
    if bucket_proxy.owner_id.to_i <= 0
      number_of_organizations = FundingTemplate.find_by(id: bucket_proxy.template_id).organizations.length
    end

    (1+bucket_proxy.fiscal_year_range_end.to_i - bucket_proxy.fiscal_year_range_start.to_i) * number_of_organizations

  end

end
