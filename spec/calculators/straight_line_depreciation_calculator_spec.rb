require 'rails_helper'
include FiscalYear

RSpec.describe StraightLineDepreciationCalculator, :type => :calculator do

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

    skip('Needs depreciation entries. Not yet testable.')
  end

  let(:test_calculator) { StraightLineDepreciationCalculator.new }

  describe '#calculate' do
    it 'calculates' do
      expect(test_calculator.calculate_on_date(@test_asset,Date.new(2014,6,30)).to_i).to eq(1916)
    end

    it 'returns purchase cost if asset is new' do
      @test_asset.depreciation_start_date = Date.today
      @test_asset.save

      expect(test_calculator.calculate(@test_asset)).to eq(@test_asset.purchase_cost)
    end

    it 'returns residual value if larger than calculated' do
      # make test_asset impossibly old
      @test_asset.depreciation_start_date = Date.new(1900,1,1)
      @test_asset.save


      expect(test_calculator.calculate(@test_asset)).to eq(@test_asset.salvage_value)
    end
    it 'returns residual value if EUL end' do
      # add a year to show that should be replaced (i.e. depreciated completed) immediately/next year
      @test_asset.depreciation_start_date = fiscal_year_end_date(Date.today) - (@test_asset.expected_useful_life+12).months
      @test_asset.save

      expect(test_calculator.calculate(@test_asset)).to eq(@test_asset.salvage_value)
    end
  end

  describe '#book_value_start' do
    it 'equals the book value end of the previous year' do
      expect(test_calculator.book_value_start(@test_asset,fiscal_year_end_date(Date.today))).to eq(test_calculator.book_value_end(@test_asset,fiscal_year_end_date(Date.today - 1.years)))
    end
  end

  describe '#book_value_end' do
    it 'has a min of 0' do
      test_date = Date.new(3000,1,1) # choose impossible date in the future
      expect(test_calculator.book_value_end(@test_asset,test_date)).to eq(0)
    end
  end

  describe '#depreciated_expense' do
    it 'is the difference of book value start and end' do
      test_date = fiscal_year_end_date(Date.today)
      book_value_start = test_calculator.book_value_start(@test_asset,test_date)
      book_value_end = test_calculator.book_value_end(@test_asset,test_date)

      expect(test_calculator.depreciated_expense(@test_asset,test_date)).to eq(book_value_start - book_value_end)
    end
  end

  describe '#accumulated_depreciation' do
    it 'is the sum of depreciated expenses' do
      val1 = test_calculator.depreciated_expense(@test_asset,fiscal_year_end_date(@test_asset.depreciation_start_date))
      val2 = test_calculator.depreciated_expense(@test_asset,fiscal_year_end_date(@test_asset.depreciation_start_date + 1.years))

      expect(test_calculator.accumulated_depreciation(@test_asset,fiscal_year_end_date(@test_asset.depreciation_start_date + 1.years))).to eq(val1 + val2)
    end
  end

end
