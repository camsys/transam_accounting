require 'rails_helper'

# Rspec for TransamGlAccountableAsset and TransamDepreciable modules
# modules extends assets with accounting

RSpec.describe Asset, :type => :model do

  let(:test_asset) { create(:buslike_asset) }
  let(:test_gla) { create(:general_ledger_account) }
  let(:test_expenditure) { create(:expenditure) }

  # ----------------------------------------------------------------
  # Rspec for TransaamGlAccountableAsset
  # GLA associations with assets
  # ----------------------------------------------------------------
  it 'HABTM glas' do
    test_gla.assets << test_asset
    test_gla.save!

    expect(test_asset.general_ledger_accounts).to include(test_gla)
  end
  it 'HABTM expenditures' do
    test_expenditure.assets << test_asset
    test_expenditure.save!

    expect(test_asset.expenditures).to include(test_expenditure)
  end

  # ----------------------------------------------------------------
  # Rspec for TransaamDepreciable
  # depreciation of assets
  # ----------------------------------------------------------------

  describe 'aliases' do
    it 'replacement value' do
      test_asset.update!(:estimated_replacement_cost => 5000)
      expect(test_asset.replacement_value).to eq(test_asset.estimated_replacement_cost)
    end
  end

  it '.depreciable_as_json' do
    results = test_asset.depreciable_as_json.to_s

    expect(results).to include(':depreciable=>true')
    expect(results).to include(':depreciation_start_date=>Wed, 01 Jan 2014')
    expect(results).to include(':book_value=>100')
    expect(results).to include(':salvage_value=>0')
    expect(results).to include(':depreciation_date=>nil')
  end
  it '.depreciation_months' do
    test_asset.update!(:depreciation_start_date => Date.today - 123.months)
    expect(test_asset.depreciation_months).to eq(123)
  end
  it '.get_depreciation_table' do
    pending('TODO')
    fail
  end
  it '.update_methods' do
    pending('TODO')
    fail
    expect(test_asset.update_methods).to include('update_book_value')
  end
  it '.update_book_value' do
    pending('TODO')
    fail
  end

  it '.set_depreciation_defaults' do
    test_depreciable_asset = create(:buslike_asset, :depreciation_start_date => nil, :depreciable => nil, :in_service_date => nil, :book_value => nil, :salvage_value => nil)

    expect(test_depreciable_asset.in_service_date).to eq(test_depreciable_asset.purchase_date)
    expect(test_depreciable_asset.depreciation_start_date).to eq(test_depreciable_asset.purchase_date)
    expect(test_depreciable_asset.book_value).to eq(test_depreciable_asset.purchase_cost.to_i)
    expect(test_depreciable_asset.salvage_value).to eq(0)
    expect(test_depreciable_asset.depreciable).to be true
  end
end
