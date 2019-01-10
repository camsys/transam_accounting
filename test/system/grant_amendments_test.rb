require "application_system_test_case"

class GrantAmendmentsTest < ApplicationSystemTestCase
  setup do
    @grant_amendment = grant_amendments(:one)
  end

  test "visiting the index" do
    visit grant_amendments_url
    assert_selector "h1", text: "Grant Amendments"
  end

  test "creating a Grant amendment" do
    visit grant_amendments_url
    click_on "New Grant Amendment"

    fill_in "Grant", with: @grant_amendment.grant_id
    click_on "Create Grant amendment"

    assert_text "Grant amendment was successfully created"
    click_on "Back"
  end

  test "updating a Grant amendment" do
    visit grant_amendments_url
    click_on "Edit", match: :first

    fill_in "Grant", with: @grant_amendment.grant_id
    click_on "Update Grant amendment"

    assert_text "Grant amendment was successfully updated"
    click_on "Back"
  end

  test "destroying a Grant amendment" do
    visit grant_amendments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Grant amendment was successfully destroyed"
  end
end
