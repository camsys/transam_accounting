require 'test_helper'

class GrantAmendmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grant_amendment = grant_amendments(:one)
  end

  test "should get index" do
    get grant_amendments_url
    assert_response :success
  end

  test "should get new" do
    get new_grant_amendment_url
    assert_response :success
  end

  test "should create grant_amendment" do
    assert_difference('GrantAmendment.count') do
      post grant_amendments_url, params: { grant_amendment: { grant_id: @grant_amendment.grant_id } }
    end

    assert_redirected_to grant_amendment_url(GrantAmendment.last)
  end

  test "should show grant_amendment" do
    get grant_amendment_url(@grant_amendment)
    assert_response :success
  end

  test "should get edit" do
    get edit_grant_amendment_url(@grant_amendment)
    assert_response :success
  end

  test "should update grant_amendment" do
    patch grant_amendment_url(@grant_amendment), params: { grant_amendment: { grant_id: @grant_amendment.grant_id } }
    assert_redirected_to grant_amendment_url(@grant_amendment)
  end

  test "should destroy grant_amendment" do
    assert_difference('GrantAmendment.count', -1) do
      delete grant_amendment_url(@grant_amendment)
    end

    assert_redirected_to grant_amendments_url
  end
end
