class AddSourceableAccountingModels < ActiveRecord::Migration[4.2]
  def change
    change_table :grants do |t|
      t.references :sourceable, :polymorphic => true
      t.boolean :active
    end
    change_table :grant_budgets do |t|
      t.boolean :active
    end

    remove_column :grants, :funding_source_id
    remove_column :grants, :grant_number


  end
end
