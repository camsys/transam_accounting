class AddActiveIndexToGeneralLedgerAccount < ActiveRecord::Migration
  def change
    add_index :general_ledger_accounts, :active, :name => :general_ledger_accounts_idx3
  end
end
