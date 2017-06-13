class AddSourceableAccountingModels < ActiveRecord::Migration
  def change
    change_table :grants do |t|
      t.references :sourceable, :polymorphic => true
      t.boolean :active
    end
    change_table :grant_budgets do |t|
      t.references :sourceable, :polymorphic => true
      t.boolean :active
    end

    remove_column :grants, :funding_source_id
    remove_column :grants, :grant_number
    remove_column :grant_budgets, :grant_id

    drop_table :assets_general_ledger_accounts


  end
end
