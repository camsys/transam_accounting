require 'rails_helper'

RSpec.describe AssetDepreciableProxy, :type => :model do

  let(:test_proxy) { AssetDepreciableProxy.new }
  let(:test_asset) { create(:buslike_asset, :expected_useful_miles => 100000) }

  it '.set_defaults' do
    skip('Needs transam_asset. Not yet testable.')

    test_proxy.set_defaults(test_asset)

    expect(test_proxy.object_key).to eq(test_asset.object_key)
    expect(test_proxy.depreciable).to eq(test_asset.depreciable)
    expect(test_proxy.depreciation_start_date).to eq(test_asset.depreciation_start_date)
    expect(test_proxy.salvage_value).to eq(test_asset.salvage_value)
    expect(test_proxy.expected_useful_life).to eq(test_asset.expected_useful_life)
    expect(test_proxy.expected_useful_miles).to eq(test_asset.expected_useful_miles)
  end
end
