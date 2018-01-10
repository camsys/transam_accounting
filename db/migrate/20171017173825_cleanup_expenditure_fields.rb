class CleanupExpenditureFields < ActiveRecord::Migration
  def change
    remove_column :expenditures, :organization_id
    remove_column :expenditures, :vendor_id
  end
end
