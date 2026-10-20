require 'rails_helper'

# Survivor-hierarchy mirror (TTPLAT-3090) of spec/calculators/depreciation_calculator_spec.rb.
# Does not reopen class Vehicle < Asset or TestOrg < Organization.
RSpec.describe DepreciationCalculator, :type => :calculator do

  let(:test_calculator) { DepreciationCalculator.new }
  let(:test_asset) { create(:transam_asset, :purchase_cost => 2000, :salvage_value => 0) }

  describe '#total_depreciation' do
    # Mirrors: spec/calculators/depreciation_calculator_spec.rb:39-41 ('is the purchase
    # cost for a percent residual value of 0'; live). Survivor:
    # DepreciationCalculator#total_depreciation, [purchase_cost(asset) - salvage_value, 0].max.
    # Added: a non-zero salvage value, to show the residual is what is subtracted.
    it 'is the purchase cost for a percent residual value of 0' do
      expect(test_calculator.total_depreciation(test_asset)).to eq(2000)

      test_asset.salvage_value = 500
      expect(test_calculator.total_depreciation(test_asset)).to eq(1500)
    end
  end
end
