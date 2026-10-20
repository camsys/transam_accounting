require 'rails_helper'

# Survivor-hierarchy mirror (TTPLAT-3090) of spec/models/asset_depreciable_proxy_spec.rb.
RSpec.describe AssetDepreciableProxy, :type => :model do

  let(:test_proxy) { AssetDepreciableProxy.new }
  let(:test_asset) do
    create(:transam_asset, :purchase_cost => 2000, :salvage_value => 750,
           :depreciation_start_date => Date.new(2021, 2, 3))
  end

  # Mirrors: spec/models/asset_depreciable_proxy_spec.rb:8-19 ('.set_defaults';
  # skipped at :9 'Needs transam_asset', so it never ran). Survivor:
  # AssetDepreciableProxy#set_defaults (asset_depreciable_proxy.rb).
  # Changed: the proxy has no expected_useful_life or expected_useful_miles accessor
  # (its attributes are object_key, depreciable, depreciation_start_date,
  # depreciation_useful_life, depreciation_purchase_cost, salvage_value). The legacy
  # expected_useful_life assertion becomes depreciation_useful_life, the field the
  # survivor copies; expected_useful_miles has no survivor counterpart and is not
  # asserted. Added: depreciation_purchase_cost.
  it '#set_defaults' do
    test_proxy.set_defaults(test_asset)

    expect(test_proxy.object_key).to eq(test_asset.object_key)
    expect(test_proxy.object_key).not_to be_blank
    expect(test_proxy.depreciable).to eq(test_asset.depreciable)
    expect(test_proxy.depreciable).to be true
    expect(test_proxy.depreciation_start_date).to eq(Date.new(2021, 2, 3))
    expect(test_proxy.salvage_value).to eq(750)
    expect(test_proxy.depreciation_useful_life).to eq(120)
    expect(test_proxy.depreciation_purchase_cost).to eq(2000)
  end
end
