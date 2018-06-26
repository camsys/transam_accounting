class AddInitialDepreciationFields < ActiveRecord::Migration[4.2]
  def change
    add_column :assets, :depreciation_useful_life, :integer, after: :depreciation_start_date
    add_column :assets, :depreciation_purchase_cost, :integer, after: :depreciation_useful_life

  end
end
