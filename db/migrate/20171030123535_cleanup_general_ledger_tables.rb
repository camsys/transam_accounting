class CleanupGeneralLedgerTables < ActiveRecord::Migration
  def change
    add_column :asset_events, :general_ledger_account_id, :integer

    remove_column :expense_types, :organization_id
    drop_table :organization_general_ledger_accounts
  end
end
