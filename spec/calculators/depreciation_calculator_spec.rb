require 'rails_helper'

include FiscalYear

RSpec.describe DepreciationCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.find_by_organization_id(self.id)
    end
  end

  class Vehicle < Asset; end

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:buslike_asset, :organization => @organization)
    @policy = create(:policy, :organization => @organization)
    @policy_item = create(:policy_item, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
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

    # it 'is 0 for a percentage residual value of 100' do
    #   @policy_item.pcnt_residual_value = 100
    #   @policy_item.save!
    #
    #   expect(test_calculator.total_depreciation(@test_asset)).to eq(0)
    # end

  end

  describe '#salvage_value' do
    it 'with no user-defined salvage value is 0 for a percent residual value of 0 ' do

      expect(test_calculator.salvage_value(@test_asset)).to eq(0)
    end

    # it 'with no user-defined salvage value is the purchase cost for a percent residual value of 100' do
    #   @policy_item.pcnt_residual_value = 100
    #   @policy_item.save!
    #
    #   expect(test_calculator.salvage_value(@test_asset)).to eq(@test_asset.purchase_cost)
    # end

    it 'chooses user-defined salvage value always if exists' do
      @policy_item.pcnt_residual_value = 50
      @policy_item.save!

      @test_asset.salvage_value = 100
      @test_asset.save!

      expect(test_calculator.salvage_value(@test_asset)).to eq(@test_asset.salvage_value)
    end
  end

  describe '#book_value_start' do
    it 'is the purchase cost if first fiscal year' do
      expect(test_calculator.book_value_start(@test_asset,fiscal_year_end_date(@test_asset.depreciation_start_date))).to eq(@test_asset.purchase_cost)
    end
  end

end
