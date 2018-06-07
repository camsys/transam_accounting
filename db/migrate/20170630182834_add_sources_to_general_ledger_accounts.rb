class AddSourcesToGeneralLedgerAccounts < ActiveRecord::Migration[4.2]
  def change
    add_reference :general_ledger_accounts, :grant
    add_reference :general_ledger_account_entries, :sourceable, polymorphic: true
  end
end
