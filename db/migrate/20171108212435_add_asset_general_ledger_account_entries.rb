class AddAssetGeneralLedgerAccountEntries < ActiveRecord::Migration
  def change
    add_reference :general_ledger_account_entries, :asset, index: true
  end
end
