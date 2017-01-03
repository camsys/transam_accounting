require 'rails_helper'

# use equipment form to check partial grant_purchases form

describe "assets/_grant_purchases_form.html.haml", :skip, :type => :view do
  it 'fields' do
    assign(:organization, create(:organization))
    test_asset = Equipment.new(:asset_type => AssetType.find_by(:class_name => 'Equipment'))
    assign(:asset, test_asset)
    render 'assets/grant_purchases_form', :f => test_asset

    expect(rendered).to have_field('asset_grant_purchases_attributes_1_grant_id')
    expect(rendered).to have_field('asset_grant_purchases_attributes_1_pcnt_purchase_cost')
  end
end
