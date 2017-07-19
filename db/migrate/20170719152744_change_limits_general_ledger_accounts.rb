class ChangeLimitsGeneralLedgerAccounts < ActiveRecord::Migration
  def change
    change_column :general_ledger_accounts, :account_number, :string, limit: nil
    change_column :general_ledger_accounts, :name, :string, limit: nil
  end
end
