require 'rails_helper'

# Rspec for TransamGlAccountableGrant module
# TransamGlAccountableGrant extends associations of a grant

# TODO since changing grant purchase to be sourceable at any level need to redo Grant model and rspec

RSpec.describe Grant, :skip, :type => :model do
  it 'has many grant budgets' do
    expect(Grant.new).to have_many(:grant_budgets)
  end
  it 'and thus has many GLAs' do
    expect(Grant.new).to have_many(:general_ledger_accounts)
  end

  it 'has many expenditures' do
    expect(Grant.new).to have_many(:expenditures)
  end

  let(:test_grant) { create(:grant) }

  describe 'associations' do
    it 'has an org' do
      expect(test_grant).to belong_to(:organization)
    end
    it 'has a funding source' do
      expect(test_grant).to belong_to(:funding_source)
    end
    it 'has many grant purchases' do
      expect(test_grant).to have_many(:grant_purchases)
    end
    it 'has many assets' do
      expect(test_grant).to have_many(:assets)
    end
    it 'has many documents' do
      expect(test_grant).to have_many(:documents)
    end
    it 'has many comments' do
      expect(test_grant).to have_many(:comments)
    end
  end

  describe 'validations' do
    it 'must have an org' do
      test_grant.organization = nil
      expect(test_grant.valid?).to be false
    end
    it 'must have a grant number' do
      test_grant.grant_number = nil
      expect(test_grant.valid?).to be false
    end
    describe 'fiscal year' do
      it 'must exist' do
        test_grant.fy_year = nil
        expect(test_grant.valid?).to be false
      end
      it 'must be greater than 1969' do
        test_grant.fy_year = 1965
        expect(test_grant.valid?).to be false
      end
    end
    it 'must have a funding source' do
      test_grant.funding_source = nil
      expect(test_grant.valid?).to be false
    end
    describe 'amount' do
      it 'must exist' do
        test_grant.amount = nil
        expect(test_grant.valid?).to be false
      end
      it 'cant be negative' do
        test_grant.amount = -1
        expect(test_grant.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(Grant.allowable_params).to eq([
                                             :organization_id,
                                             :funding_source_id,
                                             :fy_year,
                                             :grant_number,
                                             :amount,
                                             :active
                                         ])
  end

  it '.spent' do
    test_asset = create(:buslike_asset, :purchase_cost => 9000)
    create(:grant_purchase, :grant => test_grant, :asset => test_asset, :pcnt_purchase_cost => 80)

    expect(test_grant.spent).to eq(7200)
  end

  it '.balance' do
    test_asset = create(:buslike_asset, :purchase_cost => 9000)
    create(:grant_purchase, :grant => test_grant, :asset => test_asset, :pcnt_purchase_cost => 80)

    expect(test_grant.balance).to eq(test_grant.amount - 7200)
  end

  describe '.available' do
    it 'balance' do
      test_asset = create(:buslike_asset, :purchase_cost => 9000)
      create(:grant_purchase, :grant => test_grant, :asset => test_asset, :pcnt_purchase_cost => 80)

      expect(test_grant.available).to eq(test_grant.balance)
    end
    it 'no more funds' do
      test_asset = create(:buslike_asset, :purchase_cost => test_grant.amount + 1000)
      create(:grant_purchase, :grant => test_grant, :asset => test_asset)

      expect(test_grant.available).to eq(0)
    end
  end

  describe 'operating funds', :skip do
    it '.non_operating_funds' do
      test_grant.update!(:pcnt_operating_assistance => 75)

      expect(test_grant.non_operating_funds).to eq(test_grant.amount / 4.0)
    end
    it '.operating_funds' do
      test_grant.update!(:pcnt_operating_assistance => 75)

      expect(test_grant.non_operating_funds).to eq(test_grant.amount - (test_grant.amount / 4.0))
    end
  end


  describe '.federal?' do
    it 'federal' do
      expect(test_grant.federal?).to be true
    end
    it 'not federal' do
      test_grant.funding_source.update!(:funding_source_type_id => 2)

      expect(test_grant.federal?).to be false
    end
  end

  describe '.fiscal_year' do
    it 'year given' do
      expect(test_grant.fiscal_year(2010)).to eq('FY 10-11')
    end
    it 'no year given' do
      expect(test_grant.fiscal_year).to eq("FY #{test_grant.fy_year-2000}-#{test_grant.fy_year-2000+1}")
    end
  end

  it '.to_s' do
    expect(test_grant.to_s).to eq(test_grant.name)
    expect(test_grant.to_s).to eq(test_grant.grant_number)
  end
  it '.name' do
    expect(test_grant.name).to eq(test_grant.grant_number)
  end

  describe '.details', :skip do
    it 'no project' do
      expect(test_grant.details).to eq("#{test_grant.funding_source.to_s} #{test_grant.fiscal_year} ($#{test_grant.available})")
    end
    it 'project given' do
      test_grant.update!(:project_number => 'Proj-XX-XXX')
      expect(test_grant.details).to eq("#{test_grant.funding_source.to_s} #{test_grant.fiscal_year}: #{test_grant.project_number} ($#{test_grant.available})")
    end
  end

  it '.searchable_fields' do
    expect(test_grant.searchable_fields).to eq([
       :object_key,
       :grant_number,
       :funding_source
   ])
  end

  it '.set_defaults' do
    test_grant = Grant.new

    expect(test_grant.amount).to eq(0)
    expect(test_grant.fy_year).to eq((Date.today - 6.months).year)
  end
end
