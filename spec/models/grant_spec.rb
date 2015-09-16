require 'rails_helper'

# Rspec for TransamGlAccountableGrant module
# TransamGlAccountableGrant extends associations of a grant

RSpec.describe Grant, :type => :model do
  it 'has many grant budgets' do
    expect(GrantBudget.column_names).to include('grant_id')
  end
  it 'and thus has many GLAs' do
    expect(GrantBudget.column_names).to include('general_ledger_account_id')
  end

  it 'has many expenditures' do
    expect(Expenditure.column_names).to include('grant_id')
  end
end
