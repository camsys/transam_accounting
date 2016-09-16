require 'rails_helper'

RSpec.describe FundingSource, :type => :model do

  let(:test_fund) { create(:funding_source) }

  describe 'associations' do
    it 'must have a type' do
      expect(test_fund).to belong_to(:funding_source_type)
    end
    it 'has many grants' do
      expect(test_fund).to have_many(:grants)
    end
  end

  describe 'validations' do
    it 'must have a name' do
      test_fund.name = nil
      expect(test_fund.valid?).to be false
    end
    it 'must have a description' do
      test_fund.description = nil
      expect(test_fund.valid?).to be false
    end
    it 'must have a funding source type' do
      test_fund.funding_source_type = nil
      expect(test_fund.valid?).to be false
    end
    describe 'match required must be a percentage' do
      it 'state match' do
        test_fund.state_match_required = 95
        expect(test_fund.valid?).to be true

        test_fund.state_match_required = 105
        expect(test_fund.valid?).to be false
      end
      it 'fed match' do
        test_fund.federal_match_required = 95
        expect(test_fund.valid?).to be true

        test_fund.federal_match_required = 105
        expect(test_fund.valid?).to be false
      end
      it 'local match' do
        test_fund.local_match_required = 95
        expect(test_fund.valid?).to be true

        test_fund.local_match_required = 105
        expect(test_fund.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(FundingSource.allowable_params).to eq([
      :object_key,
      :name,
      :description,
      :funding_source_type_id,
      :state_match_required,
      :federal_match_required,
      :local_match_required,
      :external_id,
      :state_administered_federal_fund,
      :bond_fund,
      :formula_fund,
      :non_committed_fund,
      :contracted_fund,
      :discretionary_fund,
      :rural_providers,
      :urban_providers,
      :shared_ride_providers,
      :inter_city_bus_providers,
      :inter_city_rail_providers,
      :active
    ])
  end

  describe '.federal?' do
    it 'federal fund' do
      expect(test_fund.federal?).to be true
    end
    it 'not federal fund' do
      test_fund.funding_source_type_id = 2
      expect(test_fund.federal?).to be false
    end
  end

  it '.to_s' do
    expect(test_fund.to_s).to eq(test_fund.name)
  end

  it '.set_defaults' do
    expect(test_fund.active).to be true
  end
end
