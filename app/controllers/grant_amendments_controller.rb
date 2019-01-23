class GrantAmendmentsController < OrganizationAwareController
  before_action :set_grant

  before_action :set_grant_amendment, only: [:show, :edit, :update, :destroy]

  # GET /grant_amendments
  def index
    @grant_amendments = @grant.grant_amendments
  end

  # GET /grant_amendments/1
  def show
  end

  # GET /grant_amendments/new
  def new
    @grant_amendment = @grant.grant_amendments.build
  end

  # GET /grant_amendments/1/edit
  def edit
  end

  # POST /grant_amendments
  def create
    @grant_amendment = @grant.grant_amendments.build(grant_amendment_params)
    @grant_amendment.creator = current_user

    if @grant_amendment.save
      unless @grant_amendment.grant_num.blank?
        @grant.update(grant_num: @grant_amendment.grant_num)
      end
      redirect_to @grant, notice: 'Grant amendment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /grant_amendments/1
  def update
    if @grant_amendment.update(grant_amendment_params)
      unless @grant_amendment.grant_num.blank?
        @grant.update(grant_num: @grant_amendment.grant_num)
      end

      redirect_to @grant, notice: 'Grant amendment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /grant_amendments/1
  def destroy
    @grant_amendment.destroy
    redirect_to @grant, notice: 'Grant amendment was successfully destroyed.'
  end

  private
    def set_grant
      @grant = Grant.find_by(object_key: params[:grant_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_grant_amendment
      @grant_amendment = GrantAmendment.find_by(object_key: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grant_amendment_params
      params.require(:grant_amendment).permit(GrantAmendment.allowable_params)
    end
end
