class AddDepreciationInterval < ActiveRecord::Migration
  def change
    create_table :depreciation_interval_types do |t|
      t.string  "name",        limit: 64,  null: false
      t.string  "description", limit: 254, null: false
      t.integer "months",                  null: false
      t.boolean "active",                  null: false
    end

    change_table :policies do |t|
      t.references :depreciation_interval_type, :after => :condition_estimation_type_id
    end
  end
end
