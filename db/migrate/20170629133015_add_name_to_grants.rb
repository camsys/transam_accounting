class AddNameToGrants < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :name, :string
  end
end
