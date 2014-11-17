class CreateGrantBudgets < ActiveRecord::Migration
  def change

    drop_join_table :general_ledger_accounts, :grants

    create_table :grant_budgets do |t|
      t.references :general_ledger_account, :null => :false
      t.references :grant,                  :null => :false
      t.integer :amount,                    :null => :false
    end
   
    add_index :grant_budgets,   [:general_ledger_account_id, :grant_id], :name => :grant_budgets_idx1
   
  end
end
