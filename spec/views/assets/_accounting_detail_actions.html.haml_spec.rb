require 'rails_helper'

describe "assets/_accounting_detail_actions.html.haml", :type => :view do
  it 'actions' do
    org = create(:organization)
    asset_subtype = AssetSubtype.first
    policy = create(:policy, :organization => org)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => asset_subtype.asset_type)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => asset_subtype)
    assign(:asset, create(:buslike_asset, :book_value => 7890, :organization => org, :asset_type => asset_subtype.asset_type, :asset_subtype => asset_subtype))
    render

    expect(rendered).to have_link('Depreciation Data')
  end
end
