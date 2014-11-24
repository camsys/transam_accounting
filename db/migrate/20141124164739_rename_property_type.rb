class RenamePropertyType < ActiveRecord::Migration
  def change
    rename_column :assets, :property_type, :depreciable
  end
end
