class AddGeneralLedgerAccountToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :general_ledger_account, index: true
    add_reference :policy_asset_subtype_rules, :general_ledger_account, index: true
  end
end
