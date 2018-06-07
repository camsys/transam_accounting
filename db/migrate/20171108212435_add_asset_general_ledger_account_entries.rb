class AddAssetGeneralLedgerAccountEntries < ActiveRecord::Migration[4.2]
  def change
    add_reference :general_ledger_account_entries, :asset, index: true
  end
end
