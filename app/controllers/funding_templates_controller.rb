class FundingTemplatesController < OrganizationAwareController
  before_action :set_funding_template, only: [:show, :edit, :update, :destroy]

  add_breadcrumb 'Funding Programs', :funding_sources_path

  # GET /funding_templates
  def index

    add_breadcrumb 'Templates', funding_templates_path

    @funding_templates = FundingTemplate.all
  end

  # GET /funding_templates/1
  def show

    add_breadcrumb @funding_template.funding_source.to_s, funding_source_path(@funding_template.funding_source)
    add_breadcrumb @funding_template.to_s, funding_template_path(@funding_template)

  end

  # GET /funding_templates/new
  def new
    @funding_template = FundingTemplate.new(:funding_source_id => params[:funding_source_id])

    if @funding_template.funding_source.present?
      add_breadcrumb @funding_template.funding_source.to_s, funding_source_path(@funding_template.funding_source)
    else
      add_breadcrumb 'Templates', funding_templates_path
    end
    add_breadcrumb 'New', new_funding_template_path

  end

  # GET /funding_templates/1/edit
  def edit

    add_breadcrumb @funding_template.funding_source.to_s, funding_source_path(@funding_template.funding_source)
    add_breadcrumb @funding_template.to_s, funding_template_path(@funding_template)

  end

  # POST /funding_templates
  def create
    @funding_template = FundingTemplate.new(funding_template_params)

    if @funding_template.save
      redirect_to @funding_template, notice: 'Funding template was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /funding_templates/1
  def update
    if @funding_template.update(funding_template_params)
      redirect_to @funding_template, notice: 'Funding template was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /funding_templates/1
  def destroy
    @funding_template.destroy
    redirect_to funding_templates_url, notice: 'Funding template was successfully destroyed.'
  end

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
