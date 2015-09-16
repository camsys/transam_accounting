require 'rails_helper'

# Rspec for TransamAccountable module
# TransamAccountable extends associations of an organization

RSpec.describe Organization, :type => :model do
  it 'has many grants' do
    expect(Grant.column_names).to include('organization_id')
  end

  it 'has expenditures' do
    expect(Expenditure.column_names).to include('organization_id')
  end

  it 'has expense types' do
    expect(ExpenseType.column_names).to include('organization_id')
  end

  it 'has a chart of account and thus many GLAs' do
    expect(GeneralLedgerAccount.column_names).to include('chart_of_account_id')
    expect(ChartOfAccount.column_names).to include('organization_id')
  end

  it '.chart_of_accounts' do
    test_chart = create(:chart_of_account)
    expect(test_chart.organization.chart_of_accounts).to eq(test_chart)
  end
end
