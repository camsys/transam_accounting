require 'rails_helper'

# Rspec for TransamAccountingAssetsController
# Controller methods to update depreciation

RSpec.describe AssetsController, :type => :controller do

  let(:test_asset) { create(:buslike_asset) }

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_user) { create(:admin) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET edit_depreciation' do
    test_asset.update!(:organization => subject.current_user.organization)
    get :edit_depreciation, :id => test_asset.object_key, use_route: :edit_depreciation_inventory_path

    expect(assigns(:asset)).to eq(Asset.get_typed_asset(test_asset))
    expect(assigns(:proxy).object_key).to eq(test_asset.object_key)
    expect(assigns(:proxy).depreciable).to eq(test_asset.depreciable)
    expect(assigns(:proxy).depreciation_start_date).to eq(test_asset.depreciation_start_date)
    expect(assigns(:proxy).salvage_value).to eq(test_asset.salvage_value)
    expect(assigns(:proxy).expected_useful_life).to eq(test_asset.expected_useful_life)
    expect(assigns(:proxy).expected_useful_miles).to be nil
  end

  it 'POST update_depreciation' do
    # update required fields for a vehicle
    test_asset.update!(:depreciable => false, :manufacturer_id => 1, :manufacturer_model => 'VERSION-XX', :title_owner_organization_id => 1,:fta_ownership_type_id => 1, :fta_vehicle_type_id => 1, :fuel_type_id => 1, :serial_number => 'XXX-123456789', :vehicle_length => 40)

    post :update_depreciation, use_route: :update_depreciation_inventory_path, :asset_depreciable_proxy => {:object_key => test_asset.object_key, :depreciable => '1', :depreciation_start_date => (Date.today - 1.day).strftime('%m/%d/%Y'), :salvage_value => '1111'}
    test_asset.reload

    expect(test_asset.depreciable).to be true
    expect(test_asset.depreciation_start_date.to_date).to eq(Date.today - 1.day)
    expect(test_asset.salvage_value).to eq(1111)
    expect(test_asset.updator).to eq(subject.current_user)
  end
end
