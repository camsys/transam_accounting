class AddMoreAccountingTransamAsset < ActiveRecord::Migration[5.2]
  def change
    add_column :assets_expenditures, :transam_asset_id, :integer, after: :asset_id
    add_column :general_ledger_account_entries, :transam_asset_id, :integer, after: :asset_id
  end
end
