require 'rails_helper'

describe "assets/_accounting_purchase.html.haml", :type => :view do
  before { skip('Needs transam_asset. Not yet testable.') }

  it 'grant purchases' do
    test_asset = create(:buslike_asset)
    test_source = create(:funding_source)
    create(:grant_purchase, :sourceable => test_source, :asset => test_asset)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_link(test_source.to_s)
  end
end
