require "application_system_test_case"

class GrantApportionmentsTest < ApplicationSystemTestCase
  setup do
    @grant_apportionment = grant_apportionments(:one)
  end

  test "visiting the index" do
    visit grant_apportionments_url
    assert_selector "h1", text: "Grant Apportionments"
  end

  test "creating a Grant apportionment" do
    visit grant_apportionments_url
    click_on "New Grant Apportionment"

    click_on "Create Grant apportionment"

    assert_text "Grant apportionment was successfully created"
    click_on "Back"
  end

  test "updating a Grant apportionment" do
    visit grant_apportionments_url
    click_on "Edit", match: :first

    click_on "Update Grant apportionment"

    assert_text "Grant apportionment was successfully updated"
    click_on "Back"
  end

  test "destroying a Grant apportionment" do
    visit grant_apportionments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Grant apportionment was successfully destroyed"
  end
end
