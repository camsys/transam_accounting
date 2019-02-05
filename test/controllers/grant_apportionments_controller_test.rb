require 'test_helper'

class GrantApportionmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grant_apportionment = grant_apportionments(:one)
  end

  test "should get index" do
    get grant_apportionments_url
    assert_response :success
  end

  test "should get new" do
    get new_grant_apportionment_url
    assert_response :success
  end

  test "should create grant_apportionment" do
    assert_difference('GrantApportionment.count') do
      post grant_apportionments_url, params: { grant_apportionment: {  } }
    end

    assert_redirected_to grant_apportionment_url(GrantApportionment.last)
  end

  test "should show grant_apportionment" do
    get grant_apportionment_url(@grant_apportionment)
    assert_response :success
  end

  test "should get edit" do
    get edit_grant_apportionment_url(@grant_apportionment)
    assert_response :success
  end

  test "should update grant_apportionment" do
    patch grant_apportionment_url(@grant_apportionment), params: { grant_apportionment: {  } }
    assert_redirected_to grant_apportionment_url(@grant_apportionment)
  end

  test "should destroy grant_apportionment" do
    assert_difference('GrantApportionment.count', -1) do
      delete grant_apportionment_url(@grant_apportionment)
    end

    assert_redirected_to grant_apportionments_url
  end
end
