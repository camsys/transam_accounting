require 'rails_helper'

RSpec.describe GrantBudget, :type => :model do

  let(:test_grant_budget) { create(:grant_budget) }

  describe 'associations/validations' do
    it 'must have a GLA' do
      expect(test_grant_budget).to belong_to(:general_ledger_account)
      test_grant_budget.general_ledger_account = nil
      expect(test_grant_budget.valid?).to be false
    end
    it 'must have a grant' do
      expect(test_grant_budget).to belong_to(:grant)
      test_grant_budget.grant = nil
      expect(test_grant_budget.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(GrantBudget.allowable_params).to eq([
      :general_ledger_account_id,
      :grant_id,
      :amount
    ])
  end

  it '.name' do
    expect(test_grant_budget.name).to eq(test_grant_budget.grant.to_s+": $"+test_grant_budget.amount.to_s)
  end
  it '.to_s' do
    expect(test_grant_budget.to_s).to eq(test_grant_budget.name)
    expect(test_grant_budget.to_s).to eq(test_grant_budget.grant.to_s+": $"+test_grant_budget.amount.to_s)
  end
end
