class AddVendorToExpenditures < ActiveRecord::Migration
  def change
    change_table :expenditures do |t|
      t.references :vendor, :after => :organization_id
    end
  end
end
