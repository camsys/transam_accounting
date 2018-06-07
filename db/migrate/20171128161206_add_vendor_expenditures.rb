class AddVendorExpenditures < ActiveRecord::Migration[4.2]
  def change
    add_column :expenditures, :vendor, :string, after: :extended_useful_life_months
  end
end
