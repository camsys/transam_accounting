class FundingBucketsController < OrganizationAwareController
  # before_action :set_funding_template, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path

  before_action :set_funding_bucket, only: [:show, :edit, :update, :edit_bucket_app, :update_bucket_app, :destroy_bucket_app]
  before_action :check_filter,      :only => [:index, :new, :edit]

  INDEX_KEY_LIST_VAR    = "funding_buckets_key_list_cache_var"

  # GET /buckets
  def index
    authorize! :read, FundingBucket

    add_breadcrumb 'Funding Programs', funding_sources_path
    add_breadcrumb 'Templates', funding_templates_path
    add_breadcrumb 'Buckets', funding_buckets_path

    @templates =  FundingTemplate.all.pluck(:name, :id)
    @organizations = Organization.where(id: @organization_list).map{|o| [o.coded_name, o.id]}

    # Start to set up the query
    conditions  = []
    values      = []

    if params[:agency_id].present?
      @searched_agency_id =  params[:agency_id]
    end
    if params[:fiscal_year].present?
      @searched_fiscal_year =  params[:fiscal_year]
    end
    if params[:funds_available].present?
      @show_funds_available_only =  params[:funds_available]
    end
    if params[:searched_template].present?
      @searched_template = params[:searched_template]
    end

    # this is a search of the owner not a search on the eligibility
    # a search on the eligiblity follows the overall system filter -- not set for a super manager
    unless @searched_agency_id.blank?
      agency_filter_id = @searched_agency_id.to_i
      conditions << 'funding_buckets.owner_id = ?'
      values << agency_filter_id
    end

    unless @searched_fiscal_year.blank?
      fiscal_year_filter = @searched_fiscal_year.to_i
      conditions << 'fiscal_year = ?'
      values << fiscal_year_filter
    end

    unless @searched_template.nil?
      funding_template_id = @searched_template.to_i
      conditions << 'funding_template_id = ?'
      values << funding_template_id
    end

    if @show_funds_available_only
      conditions << 'budget_amount > budget_committed'
    end

    conditions << 'funding_buckets.active = true'

    @buckets = FundingBucket.where(conditions.join(' AND '), *values)


    # cache the set of object keys in case we need them later
    cache_list(@buckets, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @buckets }
    end
  end

  def my_funds

    @my_funds = true # so partial can use main index table with some tweaks

    authorize! :my_funds, FundingBucket

    add_breadcrumb 'Funding Programs', funding_sources_path
    add_breadcrumb 'My Funds', my_funds_funding_buckets_path

    @organizations = Organization.where(id: @organization_list).map{|o| [o.coded_name, o.id]}

    # Start to set up the query
    conditions  = []
    values      = []

    if params[:agency_id].present?
      @searched_agency_id =  params[:agency_id]
    end
    if params[:fiscal_year].present?
      @searched_fiscal_year =  params[:fiscal_year]
    end
    if params[:funds_available].present?
      @show_funds_available_only =  params[:funds_available]
    end
    if params[:searched_template].present?
      @searched_template = params[:searched_template]
    end

    # this is a search of the owner not a search on the eligibility
    # a search on the eligiblity follows the overall system filter -- not set for a super manager
    if @searched_agency_id.blank?
      conditions << 'funding_buckets.owner_id IN (?)'
      # should use organization list but organizations that the user actually belongs to
      # so bpt can see all orgs but only belong to BPT
      # transit agencies obviously belongs to all their transit agencies
      values << (current_user.organizations.ids & @organization_list)
    else
      agency_filter_id = @searched_agency_id.to_i
      conditions << 'funding_buckets.owner_id = ?'
      values << agency_filter_id
    end

    unless @searched_fiscal_year.blank?
      fiscal_year_filter = @searched_fiscal_year.to_i
      conditions << 'funding_buckets.fiscal_year <= ?'
      values << fiscal_year_filter
      conditions << '(((funding_buckets.fiscal_year + funding_sources.life_in_years) >= ?) OR (funding_sources.life_in_years IS NULL))'
      values << fiscal_year_filter
    end

    unless @searched_template.nil?
      funding_template_id = @searched_template.to_i
      conditions << 'funding_template_id = ?'
      values << funding_template_id
    end

    if @show_funds_available_only
      conditions << 'budget_amount > budget_committed'
    end

    # on My Funds - templates must be ones you are eligible for
    # on buckets index page you can search by template
    #if params[:my_funds]
    #@templates = FundingTemplate.joins(:organizations).where('funding_templates.owner_id = ? AND funding_templates_organizations.organization_id IN (?)', FundingSourceType.find_by(name: 'State').id, @organization_list)
    #buckets = FundingBucket.where('(funding_template_id IN (?) OR owner_id IN (?))',templates.ids, @organization_list)
    #@buckets = buckets.where(conditions.join(' AND '), *values)
    #end

    conditions << 'funding_buckets.active = true'

    @buckets = FundingBucket.joins(:funding_source).where(conditions.join(' AND '), *values)


    # cache the set of object keys in case we need them later
    cache_list(@buckets, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @buckets }
    end
  end

  # GET /buckets/1
  def show

    # only need to reset filter for users in super manager role who can supervise/see all organizations
    if current_user.user_organization_filters.include? UserOrganizationFilter.system_filters.first
      check_filter
    end

    authorize! :read, @funding_bucket

    add_breadcrumb @funding_bucket.funding_template.funding_source.name, funding_source_path(@funding_bucket.funding_template.funding_source)
    add_breadcrumb @funding_bucket.funding_template.name, funding_template_path(@funding_bucket.funding_template)
    add_breadcrumb @funding_bucket.to_s, funding_bucket_path(@funding_bucket)

    @funding_template = @funding_bucket.funding_template

  end

  # GET /buckets/new
  def new
    authorize! :create, FundingBucket

    add_breadcrumb 'Funding Programs', funding_sources_path
    add_breadcrumb 'Templates', funding_templates_path
    add_breadcrumb 'Buckets', funding_buckets_path
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

  def new_bucket_app

    authorize! :new_bucket_app, FundingBucket

    @funding_bucket = FundingBucket.new
  end

  # GET /buckets/1/edit
  def edit
    authorize! :update, @funding_bucket

  end

  def edit_bucket_app
    authorize! :edit_bucket_app, @funding_bucket
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
      expected_buckets = find_expected_bucket_count_from_bucket_proxy(bucket_proxy)

      if expected_buckets > @existing_buckets.length && bucket_proxy.update_conflict_option.blank?
        @update_conflict = true

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

  def create_bucket_app
    authorize! :new_bucket_app, FundingBucket

    @funding_bucket = FundingBucket.new(bucket_params)
    @funding_bucket.creator = current_user
    @funding_bucket.updator = current_user

    if @organization_list.count == 1
      @funding_bucket.owner_id = @organization_list.first
    end

    respond_to do |format|
      if @funding_bucket.save
        notify_user(:notice, "The grant application was successfully saved.")
        format.html { redirect_to my_funds_funding_buckets_path }
        format.json { render action: 'show', status: :created, location: @funding_bucket }
      else
        format.html { render action: 'new_grant' }
        format.json { render json: @funding_bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buckets/1
  def update
    authorize! :update, @funding_bucket

    respond_to do |format|
      if @funding_bucket.update(bucket_params)
        notify_user(:notice, "The bucket was successfully updated.")
        format.html { redirect_to :back }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @funding_bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_bucket_app

    authorize! :edit_bucket_app, @funding_bucket

    respond_to do |format|
      if @funding_bucket.update(bucket_params)
        notify_user(:notice, "The grant application was successfully updated.")
        format.html { redirect_to my_funds_funding_buckets_path }
        format.json { head :no_content }
      else
        format.html { render action: 'edit_bucket_app' }
        format.json { render json: @funding_bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buckets/1
  def destroy
    # currently not used
  end

  def destroy_bucket_app
    if @funding_bucket.destroy
      notify_user(:notice, "The grant application was successfully removed.")
      respond_to do |format|
        format.html {
          # check where to redirect to
          if URI(request.referer || '').path.include? "funding_buckets/#{@funding_bucket.object_key}"
            if current_user.organization_ids.include? @funding_bucket.owner_id
              redirect_to my_funds_funding_buckets_path
            else
              redirect_to funding_buckets_path
            end
          else
            redirect_to :back
          end
        }
        format.json { head :no_content }
      end
    end
  end

  def find_organizations_from_template_id
    template_id = params[:template_id]
    result = find_organizations(template_id)

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

  def find_existing_buckets_for_create
    result = FundingBucket.find_existing_buckets_from_proxy(params[:template_id], params[:start_year].to_i, params[:end_year].to_i, params[:owner_id].to_i)

    msg = "#{result.length} of the Buckets you are creating already exist. Do you want to update these Buckets' budget, ignore these Buckets, or cancel this action?"

    respond_to do |format|
      format.json { render json: {:result_count => result.length, :new_html => (render_to_string :partial => 'form_modal', :formats => [:html], :locals => {:result => result, :msg => msg, :action => 'create'}) }}
    end
  end

  def find_number_of_missing_buckets_for_update
      existing_buckets = FundingBucket.find_existing_buckets_from_proxy(params[:template_id], params[:start_year], params[:end_year], params[:owner_id]).pluck(:fiscal_year, :owner_id)
      expected_buckets = find_expected_buckets(params[:template_id], params[:start_year].to_i, params[:end_year].to_i, params[:owner_id].to_i)
      not_created_buckets = expected_buckets - existing_buckets
      template = FundingTemplate.find_by(id: params[:template_id])
      result = []
      not_created_buckets.each do |b|
        result << FundingBucket.new(funding_template: template, fiscal_year: b[0], owner_id: b[1])
      end

      msg = "#{result.length} Buckets you are updating do not yet exist. Do you want to create these Buckets, ignore these Buckets, or cancel this action?"

      respond_to do |format|
        format.json { render json: {:result_count => result.length, :new_html => (render_to_string :partial => 'form_modal', :formats => [:html], :locals => {:result => result, :msg => msg, :action => 'update'}) }}
      end
  end

  def find_expected_escalation_percent
    program_id = params[:program_id]
    result = FundingSource.find_by(id: program_id).inflation_rate

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def find_template_based_fiscal_year_range
    program_id = params[:program_id]
    program = FundingSource.find_by(id: program_id)

    result = program.find_all_valid_fiscal_years

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  protected

  def find_organizations(template_id)
    result = []
    @bucket_agency_allocations = []

    template = FundingTemplate.find_by(id: template_id)
    if template.owner == FundingSourceType.find_by(name: 'State')
      grantors = Grantor.where(id: @organization_list)
      grantors.each { |g|
        result << [g.id, g.coded_name]
      }
    else
      orgs = template.organizations.where(id: @organization_list)
      organizations = []
      if orgs.length > 0
        orgs.each { |o|
          item = [o.id, o.coded_name]
          organizations << item
        }
      else
        organizations =  Organization.find_by_sql(template.query_string).reduce([]) { |a, n| a.push([n.id, n.coded_name]) if @organization_list.include? n.id; a }
      end

      result = organizations
    end

    result
  end

  def create_new_buckets(bucket_proxy, existing_buckets=nil, create_conflict_option=nil)

    unless bucket_proxy.owner_id.to_i <= 0
      bucket = new_bucket_from_proxy(bucket_proxy)
      create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, create_conflict_option, 'Create')
    else
      bucket = new_bucket_from_proxy(bucket_proxy)
      organizations = find_organizations(bucket_proxy.template_id)


      organizations.each { |org|
        unless org[0] < 0 || params["agency_budget_id_#{org[0]}"].blank?
          bucket = new_bucket_from_proxy(bucket_proxy, org[0])
          bucket.budget_amount = params["agency_budget_id_#{org[0]}".parameterize.underscore.to_sym].to_d
          # bucket_proxy inflation percentage could be modified the same way
          create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, create_conflict_option, 'Create', org[0],)
        end
      }

    end
  end

  def update_buckets(bucket_proxy, existing_buckets=nil, update_conflict_option=nil )

    unless bucket_proxy.owner_id.to_i <= 0
      bucket = new_bucket_from_proxy(bucket_proxy)
      create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, 'Update',  update_conflict_option)
    else
      bucket = new_bucket_from_proxy(bucket_proxy)
      organizations = find_organizations(bucket_proxy.template_id)

      organizations.each { |org|
        unless org[0] < 0
          unless params["agency_budget_id_#{org[0]}"].blank?
            bucket = new_bucket_from_proxy(bucket_proxy, org[0])
            bucket.budget_amount = params["agency_budget_id_#{org[0]}".parameterize.underscore.to_sym].to_d
            # bucket_proxy inflation percentage could be modified the same way
            create_single_organization_buckets(bucket, bucket_proxy, existing_buckets, 'Update', update_conflict_option, org[0],)
          end
        end
      }

    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_funding_bucket
    @funding_bucket = FundingBucket.find_by(object_key: params[:id])
  end

  def bucket_params
    params.require(:funding_bucket).permit(FundingBucket.allowable_params)
  end

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
      if (!existing_bucket.nil? && (create_conflict_option == 'Ignore')) || (existing_bucket.nil? && update_conflict_option == 'Ignore')
          # DO NOTHING
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
        if (!existing_bucket.nil? && (create_conflict_option == 'Ignore')) || (existing_bucket.nil? && update_conflict_option == 'Ignore')
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
      if (!existing_bucket.nil? && (create_conflict_option == 'Ignore')) || (existing_bucket.nil? && update_conflict_option == 'Ignore')
        #   DO NOTHING
      elsif !existing_bucket.nil? && create_conflict_option == 'Update'
        existing_bucket.budget_amount = bucket.budget_amount
        existing_bucket.updator = current_user
        existing_bucket.save
      else
        puts bucket.inspect
        bucket.save!
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

  def find_expected_bucket_count_from_bucket_proxy bucket_proxy
    find_expected_bucket_count(bucket_proxy.template_id, bucket_proxy.fiscal_year_range_start.to_i, bucket_proxy.fiscal_year_range_end.to_i, bucket_proxy.owner_id.to_i)
  end

  def find_expected_bucket_count template_id, fiscal_year_range_start, fiscal_year_range_end, owner_id

    number_of_organizations = 1
    if owner_id <= 0
      number_of_organizations = find_organizations(template_id).length
    end

    (1+fiscal_year_range_end - fiscal_year_range_start) * number_of_organizations

  end

  def find_expected_buckets template_id, fiscal_year_range_start, fiscal_year_range_end, owner_id
    fiscal_years = (fiscal_year_range_start..fiscal_year_range_end).to_a

    orgs = [owner_id]
    if owner_id <= 0
      orgs = find_organizations(template_id).pluck(:id)
    end

    fiscal_years.product(orgs)
  end
end
