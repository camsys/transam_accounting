require 'rails_helper'

# Survivor-hierarchy mirrors (TTPLAT-3090) of spec/models/grant_purchase_spec.rb
# (the whole legacy file is skipped at :6, 'Needs transam_asset', so none of it ran).
#
# NOT mirrored, tripwire 2 (see ttplat-3090-cowork-report-a6.md):
#   'must have a source' (legacy :20-23). validates_presence_of :sourceable is commented
#     out (grant_purchase.rb:29), so valid? is true with no source.
#   'must have an asset' (legacy :24-27). valid? raises NoMethodError, because
#     total_funding_not_over_purchase_cost (grant_purchase.rb:107-109) dereferences a nil
#     transam_asset; the presence validator does not stop it from running.
RSpec.describe GrantPurchase, :type => :model do

  let(:test_purchase) { create(:grant_purchase, :pcnt_purchase_cost => 80) }

  describe 'associations' do
    # Mirrors: grant_purchase_spec.rb:11-13 ('has a source')
    it 'has a source' do
      expect(test_purchase.sourceable).to be_a(FundingSource)
      # last: the matcher's required-check nils the association on the subject
      expect(test_purchase).to belong_to(:sourceable)
    end

    # Mirrors: grant_purchase_spec.rb:14-16 ('has an asset').
    # Changed: belong_to(:asset) becomes :transam_asset (the model has no :asset). The
    # shoulda belong_to matcher is not used here: its required-check sets the association
    # to nil and calls valid?, which raises NoMethodError in
    # total_funding_not_over_purchase_cost (the defect described above), so the
    # association is asserted through its reflection.
    it 'has a transam_asset' do
      reflection = GrantPurchase.reflect_on_association(:transam_asset)
      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.klass).to eq(TransamAsset)
      expect(GrantPurchase.reflect_on_association(:asset)).to be_nil
      expect(test_purchase.transam_asset).to be_a(TransamAsset)
      expect(test_purchase.transam_asset.grant_purchases).to include(test_purchase)
    end
  end

  describe 'validations' do
    # Mirrors: grant_purchase_spec.rb:28-31 ('pcnt purchase cost must be a percentage')
    it 'pcnt purchase cost must be a percentage' do
      expect(test_purchase.valid?).to be true

      test_purchase.pcnt_purchase_cost = 101
      expect(test_purchase.valid?).to be false
      expect(test_purchase.errors[:pcnt_purchase_cost]).not_to be_empty
    end
  end

  # Mirrors: grant_purchase_spec.rb:34-36 ('#allowable_params').
  # Changed: the expected list is the model's current FORM_PARAMS (grant_purchase.rb:44),
  # which still contains :asset_id although the model has no asset association; set to
  # match the model, not the reverse. Recorded as a finding, not fixed.
  it '#allowable_params' do
    expect(GrantPurchase.allowable_params).to eq([:id, :asset_id, :global_sourceable, :sourceable_type, :sourceable_id,
                                                  :other_sourceable, :pcnt_purchase_cost, :amount, :expense_tag, :fain, :_destroy])
  end

  # Mirrors: grant_purchase_spec.rb:38-41 ('.to_s')
  it '#to_s' do
    expect(test_purchase.to_s).to eq(test_purchase.name)
    expect(test_purchase.to_s).to eq("#{test_purchase.sourceable.to_s}: 80.0%")
  end

  # Mirrors: grant_purchase_spec.rb:42-44 ('.name')
  it '#name' do
    expect(test_purchase.name).to eq("#{test_purchase.sourceable.to_s}: 80.0%")
    expect(test_purchase.name).to match(/\ATest Funding Source \d+: 80.0%\z/)
  end
end
