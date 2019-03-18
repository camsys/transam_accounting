class GrantApportionmentsController < OrganizationAwareController

  before_action :set_grant
  before_action :set_grant_apportionment, only: [:show, :edit, :update, :destroy]

  # GET /grant_apportionments
  def index
    @grant_apportionments = @grant.grant_apportionments
  end

  # GET /grant_apportionments/1
  def show
  end

  # GET /grant_apportionments/new
  def new
    @grant_apportionment = GrantApportionment.new
  end

  # GET /grant_apportionments/1/edit
  def edit
  end

  # POST /grant_apportionments
  def create
    @grant_apportionment.creator = current_user

    @grant_apportionment = GrantApportionment.new(grant_apportionment_params)

    if @grant_apportionment.save
      redirect_to @grant, notice: 'Grant apportionment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /grant_apportionments/1
  def update

    @grant_apportionment.updater = current_user

    respond_to do |format|
      if @grant_apportionment.update(grant_apportionment_params)
        notify_user(:notice, "Grant apportionment was successfully updated.")
        format.html { redirect_to @grant }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grant_apportionments/1
  def destroy
    @grant_apportionment.destroy
    redirect_to @grant, notice: 'Grant apportionment was successfully destroyed.'
  end

  private
  def set_grant
    @grant = Grant.find_by(object_key: params[:grant_id])
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_grant_apportionment
      @grant_apportionment = GrantApportionment.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grant_apportionment_params
      params.require(:grant_apportionment).permit(GrantApportionment.allowable_params)
    end
end
