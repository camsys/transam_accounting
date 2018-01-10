class ClearOutAssociationFields < ActiveRecord::Migration
  def change
    drop_table :assets_general_ledger_accounts

    remove_column :assets, :general_ledger_account_id
    remove_column :general_ledger_account_entries, :sourceable_id
    remove_column :general_ledger_account_entries, :sourceable_type
    remove_column :policy_asset_subtype_rules, :general_ledger_account_id

  end
end
