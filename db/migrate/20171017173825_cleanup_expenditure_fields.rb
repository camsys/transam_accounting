class CleanupExpenditureFields < ActiveRecord::Migration[4.2]
  def change
    remove_column :expenditures, :organization_id
    remove_column :expenditures, :vendor_id
  end
end
