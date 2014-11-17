class CreateGeneralLedgerAccountGrants < ActiveRecord::Migration
  def change

    drop_join_table :general_ledger_accounts, :grants

    create_table :general_ledger_account_grants do |t|
      t.references :general_ledger_account
      t.references :grant
      t.integer :amount
    end

  end
end
