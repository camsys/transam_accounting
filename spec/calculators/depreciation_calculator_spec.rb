require 'rails_helper'

include FiscalYear

RSpec.describe DepreciationCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.find_by_organization_id(self.id)
    end
  end

  class Vehicle < Asset; end

  before(:all) do
    @organization = create(:organization)
    @asset_subtype = AssetSubtype.first
    @policy = create(:policy, :organization => @organization)
    if(PolicyAssetSubtypeRule.find_by(policy: @policy).nil?)
      create(:policy_asset_type_rule, :policy => @policy, :asset_type => @asset_subtype.asset_type)
      create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @asset_subtype)
    end
  end

  before(:each) do
    @test_asset = create(:buslike_asset, :organization => @organization, :asset_type => @asset_subtype.asset_type, :asset_subtype => @asset_subtype)
  end


  let(:test_calculator) { DepreciationCalculator.new }

  describe '#total_depreciation' do
    it 'is 0 for a purchase price of 0' do
      @test_asset.purchase_cost = 0
      @test_asset.save!

      expect(test_calculator.total_depreciation(@test_asset)).to eq(0)
    end

    it 'is the purchase cost for a percent residual value of 0' do
      expect(test_calculator.total_depreciation(@test_asset)).to eq(@test_asset.purchase_cost)
    end

  end

  describe '#book_value_start' do
    it 'is the purchase cost if first fiscal year' do
      expect(test_calculator.book_value_start(@test_asset,fiscal_year_end_date(@test_asset.depreciation_start_date))).to eq(@test_asset.purchase_cost)
    end
  end

end
