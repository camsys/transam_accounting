require 'rails_helper'
include FiscalYear

# Rspec for TransamGlAccountableAsset and TransamDepreciable modules
# modules extends assets with accounting

RSpec.describe Asset, :type => :model do



  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:buslike_asset) }
  let(:test_gla) { create(:general_ledger_account) }

  # ----------------------------------------------------------------
  # Rspec for TransaamGlAccountableAsset
  # GLA associations with assets
  # ----------------------------------------------------------------

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
    expect(results).to include(':book_value=>2000')
    expect(results).to include(':salvage_value=>0')
    expect(results).to include(':depreciation_date=>nil')
  end
  it '.depreciation_months' do
    test_asset.update!(:depreciation_start_date => Date.today - 123.months)
    expect(test_asset.depreciation_months).to eq(123)
  end
  it '.get_depreciation_table' do
    skip('Needs depreciation entries. Not yet testable.')

    test_asset.update!(:asset_type => AssetType.find_by(:class_name => 'Vehicle'))
    create(:policy, :organization => test_asset.organization)

    test_table = test_asset.get_depreciation_table
    expect(test_table[0][:on_date]).to eq(fiscal_year_end_date(test_asset.depreciation_start_date))
    expect(test_table[0][:book_value_start]).to eq(test_asset.purchase_cost)
    expect(test_table[1][:on_date]).to eq(fiscal_year_end_date(test_asset.depreciation_start_date)+ 1.year)
    expect(test_table[1][:book_value_start]).to eq(test_table[0][:book_value_end])
    expect(test_table[1][:accumulated_depreciation]).to eq(test_table[0][:accumulated_depreciation]+test_table[1][:depreciated_expense])
  end
  it '.update_book_value' do
    skip('Needs depreciation entries. Not yet testable.')

    test_asset.update!(:asset_type => AssetType.find_by(:class_name => 'Vehicle'))
    test_policy = create(:policy, :organization => test_asset.organization)

    expect(test_asset.book_value).to eq(test_asset.purchase_cost)
    test_asset.update_book_value
    test_asset.reload
    expect(test_asset.book_value).to be < test_asset.purchase_cost
    expect(test_asset.current_depreciation_date).to eq(test_policy.current_depreciation_date)
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
