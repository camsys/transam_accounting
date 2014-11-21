class CreateExpenditures < ActiveRecord::Migration
  def change
    
    create_table :expense_types do |t|
      t.references :organization,                         :null => :false
      t.string     :name,                :limit => 64,    :null => :false
      t.string     :description,         :limit => 254,   :null => :false
      t.boolean    :active
    end

    add_index :expense_types,   :organization_id,     :name => :expense_types_idx1
    add_index :expense_types,   :name,                :name => :expense_types_idx2


    create_table :expenditures do |t|
      
      t.string     :object_key,            :limit => 12,  :null => :false
      t.references :organization,                         :null => :false
      t.references :general_ledger_account,               :null => :false
      t.references :grant
      t.references :expense_type,                         :null => :false
      t.date       :expense_date,                         :null => :false      
      t.string     :description,           :limit => 256, :null => :false
      t.integer    :amount,                               :null => :false
      t.integer    :pcnt_from_grant,                      :null => :false
      t.timestamps
    end

    add_index :expenditures,   :object_key,                 :name => :expenditures_idx1
    add_index :expenditures,   :organization_id,            :name => :expenditures_idx2
    add_index :expenditures,   :general_ledger_account_id,  :name => :expenditures_idx3
    add_index :expenditures,   :expense_type_id,            :name => :expenditures_idx4

    
    # Join table for exopenditures and assets
    create_join_table :assets, :expenditures    
    # and index it for mysql    
    add_index :assets_expenditures,   [:asset_id, :expenditure_id], :name => :assets_expenditures_idx1
    
  end
  
end
