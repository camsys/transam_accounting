require 'rails_helper'

RSpec.describe GeneralLedgerAccount, :type => :model do

  let(:test_gla) { create(:general_ledger_account) }

  describe 'associations/validations' do
    it 'must have a chart of account' do
      expect(test_gla).to belong_to(:chart_of_account)
    end
    it 'must have a gla type' do
      expect(test_gla).to belong_to(:general_ledger_account_type)
      test_gla.general_ledger_account_type = nil
      expect(test_gla.valid?).to be false
    end
    it 'must have a name' do
      test_gla.name = nil
      expect(test_gla.valid?).to be false
    end
    it 'must have an acct number' do
      test_gla.account_number = nil
      expect(test_gla.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(GeneralLedgerAccount.allowable_params).to eq([:chart_of_account_id, :general_ledger_account_type_id, :general_ledger_account_subtype_id, :name, :account_number, :active, {:grant_budgets_attributes=>[GrantBudget.allowable_params]}])
  end

  it '.to_s' do
    expect(test_gla.to_s).to eq(test_gla.account_number)
  end

  it '.set_defaults' do
    expect(test_gla.active).to be true
  end
end
