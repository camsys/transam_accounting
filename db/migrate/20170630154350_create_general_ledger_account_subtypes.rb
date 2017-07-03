class CreateGeneralLedgerAccountSubtypes < ActiveRecord::Migration
  def change
    create_table :general_ledger_account_subtypes do |t|
      t.references :general_ledger_account_type
      t.string :name
      t.string :description
      t.boolean :active

      t.timestamps
    end

    add_reference :general_ledger_accounts, :general_ledger_account_subtype, after: :general_ledger_account_type_id
    add_reference :organization_general_ledger_accounts, :general_ledger_account_subtype, after: :general_ledger_account_type_id
  end
end
