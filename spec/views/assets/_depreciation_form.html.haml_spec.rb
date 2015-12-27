require 'rails_helper'

describe "assets/_depreciation_form.html.haml", :type => :view do
  it 'fields', :skip do
    assign(:proxy, AssetDepreciableProxy.new(:object_key => create(:buslike_asset).object_key))
    render

    expect(rendered).to have_field('asset_depreciable_proxy_depreciable')
    expect(rendered).to have_field('asset_depreciable_proxy_depreciation_start_date')
    expect(rendered).to have_field('asset_depreciable_proxy_salvage_value')
  end
end
