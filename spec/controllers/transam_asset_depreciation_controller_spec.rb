require 'rails_helper'

# Survivor-hierarchy mirrors (TTPLAT-3090) of spec/controllers/assets_controller_spec.rb
# (skipped at :8, 'Needs transam_asset', so neither example ran). The actions live in
# lib/transam_accounting/transam_accounting_assets_controller.rb:59 and :72 and resolve the
# asset through Rails.application.config.asset_base_class_name (TransamAsset here), not
# legacy Asset, so no app change is needed. Does not reopen TestOrg < Organization.
RSpec.describe AssetsController, :type => :controller do

  let(:test_user) { create(:admin) }
  let(:test_asset) do
    create(:transam_asset, :organization => test_user.organization, :salvage_value => 750,
           :depreciation_start_date => Date.new(2021, 2, 3))
  end

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  # Mirrors: spec/controllers/assets_controller_spec.rb:28-39 ('GET edit_depreciation').
  # Changed: the legacy assertion assigns(:asset) == Asset.get_typed_asset(test_asset)
  # becomes the TransamAsset itself; expected_useful_life / expected_useful_miles are not
  # on AssetDepreciableProxy (see transam_asset_depreciable_proxy_spec.rb), so the proxy's
  # depreciation_useful_life and depreciation_purchase_cost are asserted instead.
  it 'GET edit_depreciation' do
    get :edit_depreciation, params: {:id => test_asset.object_key}

    expect(response).to have_http_status(:ok)
    expect(assigns(:asset)).to eq(test_asset)
    expect(assigns(:asset)).to be_a(TransamAsset)
    expect(assigns(:proxy).object_key).to eq(test_asset.object_key)
    expect(assigns(:proxy).depreciable).to be true
    expect(assigns(:proxy).depreciation_start_date).to eq(Date.new(2021, 2, 3))
    expect(assigns(:proxy).salvage_value).to eq(750)
    expect(assigns(:proxy).depreciation_useful_life).to eq(120)
    expect(assigns(:proxy).depreciation_purchase_cost).to eq(2000)
  end

  # Mirrors: spec/controllers/assets_controller_spec.rb:41-52 ('POST update_depreciation').
  # Changed: the legacy update! of vehicle-only required fields is dropped (TransamAsset
  # has none); the legacy assertion test_asset.updator == current_user is dropped:
  # updator exists only on legacy Asset (core asset.rb:126) and this action never sets it.
  # Recorded as a gap, not added.
  it 'POST update_depreciation' do
    test_asset.update!(:depreciable => false)
    start_date = Date.today - 1.day

    post :update_depreciation, params: {:id => test_asset.object_key, :asset_depreciable_proxy => {:object_key => test_asset.object_key, :depreciable => '1',
                                        :depreciation_start_date => start_date.strftime('%m/%d/%Y'), :salvage_value => '1111'}}
    test_asset.reload

    expect(response).to redirect_to(inventory_path(test_asset))
    expect(test_asset.depreciable).to be true
    expect(test_asset.depreciation_start_date.to_date).to eq(start_date)
    expect(test_asset.salvage_value).to eq(1111)
  end
end
