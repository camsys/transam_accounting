require 'rails_helper'

# Rspec for TransamGlAccountableGrant module
# TransamGlAccountableGrant extends associations of a grant

RSpec.describe Grant, :type => :model do
  it 'has many grant budgets' do
    expect(Grant.new).to have_many(:grant_budgets)
  end
  it 'and thus has many GLAs' do
    expect(Grant.new).to have_many(:general_ledger_accounts)
  end

  it 'has many expenditures' do
    expect(Grant.new).to have_many(:expenditures)
  end
end
