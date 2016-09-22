require 'rails_helper'

describe "assets/_grant_purchases.html.haml", :type => :view do
  it 'grant purchases' do
    test_asset = create(:buslike_asset)
    test_grant = create(:grant)
    create(:grant_purchase, :grant => test_grant, :asset => test_asset)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_link(test_grant.grant_number)
  end
end
