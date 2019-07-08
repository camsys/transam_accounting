class AddIndicesDepreciationEntries < ActiveRecord::Migration[5.2]
  def change
    add_index(:depreciation_entries, [:transam_asset_id, :event_date, :description], unique: true)
  end
end
