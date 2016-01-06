require 'rails_helper'

RSpec.describe ChartOfAccount, :type => :model do

  let(:test_chart) { build_stubbed(:chart_of_account) }

  describe 'associations' do
    it 'has an org' do
      expect(test_chart).to belong_to(:organization)
    end
    it 'has many GLAs' do
      expect(test_chart).to have_many(:general_ledger_accounts)
    end
  end

  it 'must have an organization' do
    expect(test_chart.attributes).to include('organization_id')
    test_chart.organization = nil
    expect(test_chart.valid?).to be false
  end

  it '#allowable_params' do
    expect(ChartOfAccount.allowable_params).to eq([
      :organization_id,
      :active
    ])
  end

  it '.name' do
    expect(test_chart.name).to eq('Chart of Accounts')
  end
  it '.to_s' do
    expect(test_chart.to_s).to eq('Chart of Accounts')
    expect(test_chart.to_s).to eq(test_chart.name)
  end

  it '.set_defaults' do
    expect(test_chart.active).to be true
  end
end
