class GrantsController < OrganizationAwareController

  authorize_resource

  # Include the fiscal year mixin
  include FiscalYear

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Grants", :grants_path

  before_action :set_grant, :only => [:show, :edit, :update, :destroy, :summary_info, :fire_workflow_event]
  before_action :reformat_date_fields, only: [:create, :update]

  before_action :set_paper_trail_whodunnit

  INDEX_KEY_LIST_VAR    = "grants_key_list_cache_var"

  def index

     # Start to set up the query
    conditions  = {}

    conditions[:owner_id] = @organization_list

    if params[:global_sourceable]
      @sourceable = GlobalID::Locator.locate params[:global_sourceable]
        conditions[:sourceable] = @sourceable
    end

    @fiscal_year = params[:fiscal_year]
    unless @fiscal_year.blank?
      @fiscal_year = @fiscal_year.to_i
      conditions[:fy_year] = @fiscal_year
    end

    @state = params[:state]
    if @state == "default" || @state.blank?
      conditions[:state] = ["in_development", "open"]
    elsif @state != "all"
      conditions[:state] = @state
    end

    # TODO fix for sourceable
    @grants = Grant.where(conditions)

    # cache the set of object keys in case we need them later
    cache_list(@grants, INDEX_KEY_LIST_VAR)

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

    @grant = Grant.new(:sourceable_id => params[:sourceable_id])

  end

  # GET /grants/1/edit
  def edit

    add_breadcrumb @grant.sourceable, eval(@grant.sourceable_path)
    add_breadcrumb @grant.to_s, grant_path(@grant)
    add_breadcrumb "Update"

  end

  # POST /grants
  # POST /grants.json
  def create

    @grant = Grant.new(grant_params.except(:contributor_id))
    if params[:grant][:contributor_id] == 'multiple'
      @grant.has_multiple_contributors = true
    elsif params[:grant][:contributor_id].to_i > 0
      @grant.contributor_id = params[:grant][:contributor_id]
    end

    @grant.creator = current_user
    @grant.updater = current_user

    respond_to do |format|
      if @grant.save
        notify_user(:notice, "The grant was successfully saved.")
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

    if params[:grant][:contributor_id] == 'multiple'
      @grant.has_multiple_contributors = true
    elsif params[:grant][:contributor_id].to_i > 0
      @grant.contributor_id = params[:grant][:contributor_id]
    end

    @grant.updater = current_user

    respond_to do |format|
      if @grant.update(grant_params.except(:contributor_id))
        notify_user(:notice, "The grant was successfully updated.")
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
    notify_user(:notice, "The grant was successfully removed.")

    respond_to do |format|
      format.html { redirect_to grants_url }
      format.json { head :no_content }
    end
  end

  def fire_workflow_event

    event_name = params[:event]

    if Grant.event_names.include? event_name
      if @grant.fire_state_event(event_name)
        event = WorkflowEvent.new
        event.creator = current_user
        event.accountable = @grant
        event.event_type = event_name
        event.save
      else
        notify_user(:alert, "Could not #{event_name.humanize} grant #{@grant}")
      end
    else
      notify_user(:alert, "#{event_name} is not a valid event for a grant")
    end

    redirect_back(fallback_location: root_path)

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find_by(object_key: params[:id], owner_id: @organization_list)

      if @grant.nil?
       if Grant.find_by(object_key: params[:id]).nil?
          redirect_to '/404'
        else
          notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
          redirect_to grants_path
        end
        return
      end
    end

    def grant_params
      params.require(:grant).permit(Grant.allowable_params)
    end

  def reformat_date_fields
    params[:grant][:award_date] = reformat_date(params[:grant][:award_date]) unless params[:grant][:award_date].blank?
  end

  def reformat_date(date_str)
    form_date = Date.strptime(date_str, '%m/%d/%Y')
    return form_date.strftime('%Y-%m-%d')
  end

end
