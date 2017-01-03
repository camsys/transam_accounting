require 'rails_helper'

RSpec.describe Expenditure, :type => :model do

  let(:test_expenditure) { create(:expenditure) }

  describe 'associations' do
    it 'has an org' do
      expect(test_expenditure).to belong_to(:organization)
    end
    it 'has a gla' do
      expect(test_expenditure).to belong_to(:general_ledger_account)
    end
    it 'has a grant' do
      expect(test_expenditure).to belong_to(:grant)
    end
    it 'has an expense type' do
      expect(test_expenditure).to belong_to(:expense_type)
    end
    it 'has a vendor' do
      expect(test_expenditure).to belong_to(:vendor)
    end
  end

  describe 'validations' do
    it 'must have a org' do
      test_expenditure.organization = nil
      expect(test_expenditure.valid?).to be false
    end
    it 'must have an expense type' do
      test_expenditure.expense_type = nil
      expect(test_expenditure.valid?).to be false
    end
    it 'must have an expense date' do
      test_expenditure.expense_date = nil
      expect(test_expenditure.valid?).to be false
    end
    it 'must have a description' do
      test_expenditure.description = nil
      expect(test_expenditure.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Expenditure.allowable_params).to eq([
      :general_ledger_account_id,
      :grant_id,
      :expense_type_id,
      :vendor_id,
      :expense_date,
      :description,
      :amount,
      :pcnt_from_grant,
      :asset_ids => []
    ])
  end

  it '.to_s' do
    expect(test_expenditure.to_s).to eq(test_expenditure.name)
    expect(test_expenditure.to_s).to eq(test_expenditure.description)
  end
  it '.name' do
    expect(test_expenditure.name).to eq(test_expenditure.description)
  end
  it '.searchable_fields' do
    expect(test_expenditure.searchable_fields).to eq([
      :object_key,
      :general_ledger_account,
      :grant,
      :expense_type,
      :name,
      :description
    ])
  end

  it '.set_defaults' do
    expect(test_expenditure.amount).to eq(0)
    expect(test_expenditure.pcnt_from_grant).to eq(0)
    expect(test_expenditure.expense_date).to eq(Date.today)
  end
end
