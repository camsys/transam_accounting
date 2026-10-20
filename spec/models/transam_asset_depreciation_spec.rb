require 'rails_helper'

# Survivor-hierarchy mirrors (TTPLAT-3090) of the depreciation examples in
# spec/models/asset_spec.rb, which exercise legacy Asset + TransamDepreciable.
# The survivor counterpart is TransamValuable on TransamAsset (wired into the dummy
# by spec/dummy/config/initializers/system_config_extensions.rb).
RSpec.describe TransamAsset, :type => :model do

  let(:test_asset) { create(:transam_asset) }

  # Mirrors: spec/models/asset_spec.rb:37-44 ('.depreciable_as_json'; live, asserts
  # five keys). Survivor: TransamValuable#depreciable_as_json (transam_valuable.rb:125).
  # Changed: legacy asserted book_value 2000 and depreciation_date nil, which held
  # because legacy depreciation never ran. The survivor's after_save
  # (update_asset_book_value) does run, so book_value is checked against the
  # depreciation entries it was derived from, and depreciation_date is non-nil.
  it '#depreciable_as_json' do
    asset = create(:transam_asset, :depreciation_start_date => Date.new(2014, 1, 1), :salvage_value => 500)
    asset.reload
    results = asset.depreciable_as_json

    expect(results[:depreciable]).to be true
    expect(results[:depreciation_start_date]).to eq(Date.new(2014, 1, 1))
    expect(results[:salvage_value]).to eq(500)
    expect(results[:book_value]).to eq(asset.depreciation_entries.sum(:book_value))
    expect(results[:book_value]).to be > 0
    expect(results[:depreciation_date]).to eq(asset.current_depreciation_date)
    expect(results[:depreciation_date]).not_to be_nil
    expect(results.keys).to eq([:depreciable, :depreciation_start_date, :book_value, :salvage_value, :depreciation_date])
  end

  # Mirrors: spec/models/asset_spec.rb:46-49 ('.depreciation_months'; live).
  # Survivor: TransamValuable#depreciation_months (transam_valuable.rb:136).
  # Added: the explicit on_date/start_date arguments, which legacy did not exercise.
  it '#depreciation_months' do
    test_asset.update!(:depreciation_start_date => Date.today - 123.months)
    expect(test_asset.depreciation_months).to eq(123)

    expect(test_asset.depreciation_months(Date.new(2020, 6, 1), Date.new(2019, 1, 1))).to eq(17)
  end

  # Mirrors: spec/models/asset_spec.rb:76-84 ('.set_depreciation_defaults'; live,
  # asserts five attributes). Survivor: TransamValuable#set_depreciation_defaults
  # (transam_valuable.rb:245, protected, before_validation).
  # Changed: the legacy assertion 'in_service_date ||= purchase_date' is dropped.
  # TransamAsset validates in_service_date presence (transam_asset.rb:73), so it
  # cannot be nil going in. The survivor's six lines are asserted instead.
  describe '#set_depreciation_defaults' do
    let(:purchase_date) { Date.new(2020, 1, 15) }
    let(:in_service_date) { Date.new(2020, 3, 1) }
    let(:new_asset) do
      build(:transam_asset, :purchase_cost => 2000, :purchase_date => purchase_date, :in_service_date => in_service_date,
            :depreciation_start_date => nil, :depreciation_purchase_cost => nil, :book_value => nil,
            :salvage_value => nil, :depreciable => nil)
    end

    it 'fills the defaults on a new record' do
      new_asset.valid?

      expect(new_asset.depreciation_start_date).to eq(in_service_date)
      expect(new_asset.depreciation_purchase_cost).to eq(2000)
      expect(new_asset.book_value).to eq(2000)
      expect(new_asset.salvage_value).to eq(0)
      expect(new_asset.depreciable).to be true
      # unless new_record?
      expect(new_asset.depreciation_useful_life).to be_nil
    end

    it 'does not overwrite values that are already set' do
      new_asset.assign_attributes(:depreciation_start_date => Date.new(2021, 1, 1), :depreciation_purchase_cost => 1800,
                                  :book_value => 1500, :salvage_value => 300, :depreciable => false)
      new_asset.valid?

      expect(new_asset.depreciation_start_date).to eq(Date.new(2021, 1, 1))
      expect(new_asset.depreciation_purchase_cost).to eq(1800)
      expect(new_asset.book_value).to eq(1500)
      expect(new_asset.salvage_value).to eq(300)
      expect(new_asset.depreciable).to be false
    end

    it 'sets depreciation_useful_life from expected_useful_life, after create and on a persisted record' do
      # after_create :set_depreciation_useful_life; the factory's policy rule gives 120
      expect(test_asset.reload.depreciation_useful_life).to eq(120)

      test_asset.update_columns(:depreciation_useful_life => nil)
      test_asset.valid?
      expect(test_asset.depreciation_useful_life).to eq(120)
    end
  end
end
