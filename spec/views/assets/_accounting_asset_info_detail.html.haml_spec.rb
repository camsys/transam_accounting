require 'rails_helper'

describe "assets/_accounting_asset_info_detail.html.haml", :type => :view do
  it 'book value' do
    org = create(:organization)
    asset_subtype = AssetSubtype.first
    policy = create(:policy, :organization => org)
    create(:policy_asset_type_rule, :policy => policy, :asset_type => asset_subtype.asset_type)
    create(:policy_asset_subtype_rule, :policy => policy, :asset_subtype => asset_subtype)
    render 'assets/accounting_asset_info_detail', :asset => create(:buslike_asset, :book_value => 7890, :organization => org, :asset_type => asset_subtype.asset_type, :asset_subtype => asset_subtype)

    expect(rendered).to have_content('$7,890')
  end
end
