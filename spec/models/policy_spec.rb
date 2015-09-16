require 'rails_helper'
include FiscalYear

# Rspec for TransamAccountingPolicy module
# TransamAccountingPolicy extends policy with accounting

RSpec.describe Policy, :type => :model do

  let(:test_policy) { create(:policy) }

  it 'has a depreciation calculation type' do
    expect(test_policy.attributes).to include('depreciation_calculation_type_id')
  end
  it 'has a depreciation interval' do
    expect(test_policy.attributes).to include('depreciation_interval_type_id')
  end

  it 'form params' do
    expect(TransamAccountingPolicy::FORM_PARAMS).to eq([
      :depreciation_calculation_type_id,
      :depreciation_interval_type_id
    ])
  end

  describe '.depreciation_date' do
    it 'monthly' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Monthly'))

      expect(test_policy.depreciation_date(Date.today)).to eq(Date.today.end_of_month)
      other_date = Date.today - 1.week
      expect(test_policy.depreciation_date(other_date)).to eq(other_date.end_of_month)
    end
    it 'quarterly' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Quarterly'))

      expect(test_policy.depreciation_date(Date.today)).to eq(Date.today.end_of_quarter)
      other_date = Date.today - 1.week
      expect(test_policy.depreciation_date(other_date)).to eq(other_date.end_of_quarter)
    end
    it 'annually' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Annually'))

      expect(test_policy.depreciation_date(Date.today)).to eq(fiscal_year_end_date(Date.today))
      other_date = Date.today - 1.week
      expect(test_policy.depreciation_date(other_date)).to eq(fiscal_year_end_date(other_date))
    end
  end
  describe '.current_depreciation_date' do
    it 'monthly' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Monthly'))

      expect(test_policy.current_depreciation_date).to eq((Date.today-1.month).end_of_month)
    end
    it 'quarterly' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Quarterly'))

      expect(test_policy.current_depreciation_date).to eq((Date.today-3.months).end_of_quarter)
    end
    it 'annually' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Annually'))

      expect(test_policy.current_depreciation_date).to eq(fiscal_year_end_date(Date.today-1.year))
    end
  end
  describe '.next_depreciation_date' do
    it 'monthly' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Monthly'))

      expect(test_policy.next_depreciation_date).to eq(test_policy.depreciation_date(Date.today))
    end
    it 'quarterly' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Quarterly'))

      expect(test_policy.next_depreciation_date).to eq(test_policy.depreciation_date(Date.today))
    end
    it 'annually' do
      test_policy.update!(:depreciation_interval_type => DepreciationIntervalType.find_by(:name => 'Annually'))

      expect(test_policy.next_depreciation_date).to eq(test_policy.depreciation_date(Date.today))
    end
  end

  it '.set_defaults' do
    expect(test_policy.depreciation_calculation_type).to eq(DepreciationCalculationType.find_by(:name => 'Straight Line'))
    expect(test_policy.depreciation_interval_type).to eq(DepreciationIntervalType.find_by(:name => 'Annually'))
  end
end
