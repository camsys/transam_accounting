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
    it 'responds to orgs' do
      expect(test_fund).to have_and_belong_to_many(:organizations)
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
      it 'match required' do
        test_fund.match_required = 95
        expect(test_fund.valid?).to be true

        test_fund.match_required = 105
        expect(test_fund.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(FundingSource.allowable_params).to eq([
      :object_key,
      :name,
      :full_name,
      :description,
      :details,
      :funding_source_type_id,
      :life_in_years,
      :match_required,
      :fy_start,
      :fy_end,
      :formula_fund,
      :discretionary_fund,
      :inflation_rate,
      {:organization_ids=>[]},
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
