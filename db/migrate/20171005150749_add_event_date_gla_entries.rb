class AddEventDateGlaEntries < ActiveRecord::Migration
  def change
    add_column :general_ledger_account_entries, :event_date, :date, after: :general_ledger_account_id
  end
end
