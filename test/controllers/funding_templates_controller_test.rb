require 'test_helper'

class FundingTemplatesControllerTest < ActionController::TestCase
  setup do
    @funding_template = funding_templates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:funding_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create funding_template" do
    assert_difference('FundingTemplate.count') do
      post :create, funding_template: { contributer_id: @funding_template.contributer_id, description: @funding_template.description, federal_match_required: @funding_template.federal_match_required, funding_source_id: @funding_template.funding_source_id, local_match_required: @funding_template.local_match_required, name: @funding_template.name, owner_id: @funding_template.owner_id, recurring: @funding_template.recurring, state_match_required: @funding_template.state_match_required, template_types_id: @funding_template.template_types_id }
    end

    assert_redirected_to funding_template_path(assigns(:funding_template))
  end

  test "should show funding_template" do
    get :show, id: @funding_template
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @funding_template
    assert_response :success
  end

  test "should update funding_template" do
    patch :update, id: @funding_template, funding_template: { contributer_id: @funding_template.contributer_id, description: @funding_template.description, federal_match_required: @funding_template.federal_match_required, funding_source_id: @funding_template.funding_source_id, local_match_required: @funding_template.local_match_required, name: @funding_template.name, owner_id: @funding_template.owner_id, recurring: @funding_template.recurring, state_match_required: @funding_template.state_match_required, template_types_id: @funding_template.template_types_id }
    assert_redirected_to funding_template_path(assigns(:funding_template))
  end

  test "should destroy funding_template" do
    assert_difference('FundingTemplate.count', -1) do
      delete :destroy, id: @funding_template
    end

    assert_redirected_to funding_templates_path
  end
end
