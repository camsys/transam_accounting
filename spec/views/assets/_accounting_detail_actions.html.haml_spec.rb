require 'rails_helper'

describe "assets/_accounting_detail_actions.html.haml", :type => :view do
  it 'actions' do
    assign(:asset, create(:buslike_asset))
    render

    expect(rendered).to have_link('Depreciation Data')
  end
end
