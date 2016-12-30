require 'rails_helper'

describe "assets/_accounting_asset_dt_columns.html.haml", :type => :view do
  it 'info' do
    org = create(:organization)
    asset_subtype = AssetSubtype.first
    policy = create(:policy, :organization => org)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => asset_subtype.asset_type)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => asset_subtype)

    render 'assets/accounting_asset_dt_columns', :a => create(:buslike_asset, :book_value => 54321, :organization => org, :asset_type => asset_subtype.asset_type, :asset_subtype => asset_subtype)

    expect(rendered).to have_content('$54,321')
  end
end
