class CreateGeneralLedgerAccountEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :general_ledger_account_entries do |t|
      t.string :object_key, limit: 12
      t.references :general_ledger_account, index: { name: 'general_ledger_account_entry_general_ledger_account_idx' }
      t.string :description
      t.decimal :amount

      t.timestamps
    end
  end
end
