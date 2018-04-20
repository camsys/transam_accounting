require 'rails_helper'

# Rspec for TransamAccountable module
# TransamAccountable extends associations of an organization

RSpec.describe Organization, :type => :model do
  it 'has many grants' do
    expect(Organization.new).to have_many(:grants)
  end

  it 'has a chart of account and thus many GLAs' do
    expect(Organization.new).to have_one(:chart_of_account)
    expect(Organization.new).to have_many(:general_ledger_accounts)
  end

  it '.chart_of_accounts' do
    test_chart = create(:chart_of_account)
    expect(test_chart.organization.chart_of_accounts).to eq(test_chart)
  end
end
