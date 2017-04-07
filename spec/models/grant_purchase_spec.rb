require 'rails_helper'

RSpec.describe GrantPurchase, :type => :model do

  let(:test_purchase) { create(:grant_purchase) }

  describe 'associations' do
    it 'has a source' do
      expect(test_purchase).to belong_to(:sourceable)
    end
    it 'has an asset' do
      expect(test_purchase).to belong_to(:asset)
    end
  end

  describe 'validations' do
    it 'must have a source' do
      test_purchase.sourceable = nil
      expect(test_purchase.valid?).to be false
    end
    it 'must have an asset' do
      test_purchase.asset = nil
      expect(test_purchase.valid?).to be false
    end
    it 'pcnt purchase cost must be a percentage' do
      test_purchase.pcnt_purchase_cost = 101
      expect(test_purchase.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(GrantPurchase.allowable_params).to eq([
      :id,
      :asset,
      :grant,
      :grant_id,
      :pcnt_purchase_cost,
      :_destroy
    ])
  end

  it '.to_s' do
    expect(test_purchase.to_s).to eq(test_purchase.name)
    expect(test_purchase.to_s).to eq("#{test_purchase.sourceable.to_s}: #{test_purchase.pcnt_purchase_cost}%")
  end
  it '.name' do
    expect(test_purchase.name).to eq("#{test_purchase.sourceable.to_s}: #{test_purchase.pcnt_purchase_cost}%")
  end

  it '.set_defaults' do
    expect(GrantPurchase.new.pcnt_purchase_cost).to eq(0)
  end
end
