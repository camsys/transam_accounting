class AddAccountingTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_reference :grant_purchases, :transam_asset, after: :asset_id
    add_reference :depreciation_entries, :transam_asset, after: :asset_id
    add_reference :assets_expenditures, :transam_asset, after: :asset_id
    add_reference :general_ledger_account_entries, :transam_asset, after: :asset_id

    add_column :transam_assets, :depreciable, :boolean, after: :in_backlog
    add_column :transam_assets, :depreciation_start_date, :date, after: :depreciable
    add_column :transam_assets, :current_depreciation_date, :date, after: :depreciation_start_date
    add_column :transam_assets, :depreciation_useful_life, :integer, after: :current_depreciation_date
    add_column :transam_assets, :depreciation_purchase_cost, :integer, after: :depreciation_useful_life
    add_column :transam_assets, :book_value, :integer, after: :depreciation_purchase_cost
    add_column :transam_assets, :salvage_value, :integer, after: :book_value
  end
end
