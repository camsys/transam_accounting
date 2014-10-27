class AddAccountingTables < ActiveRecord::Migration
  def change

    create_table :chart_of_accounts do |t|
      t.string     :object_key,            :limit => 12,  :null => :false
      t.references :organization,                         :null => :false
      t.boolean    :active
      t.timestamps
    end

    add_index :chart_of_accounts, :object_key,            :unique => :true, :name => :chart_of_accounts_idx1
    add_index :chart_of_accounts, :organization_id,       :unique => :true, :name => :chart_of_accounts_idx2

    create_table :general_ledger_account_types do |t|
      t.string     :name,                :limit => 64, :null => :false
      t.string     :description,         :limit => 254,:null => :false
      t.boolean    :active
    end
    
    create_table :general_ledger_accounts do |t|
      
      t.string     :object_key,            :limit => 12,  :null => :false
      t.references :chart_of_account,                     :null => :false
      t.references :general_ledger_account_type,          :null => :false
      t.string     :account_number,        :limit => 32,  :null => :false
      t.string     :name,                  :limit => 64,  :null => :false      
      t.boolean    :active
      t.timestamps

    end

    add_index :general_ledger_accounts, :object_key,            :unique => :true, :name => :general_ledger_accounts_idx1
    add_index :general_ledger_accounts, :chart_of_account_id,                     :name => :general_ledger_accounts_idx2

    # Join table for assets and general ledger accounts
    create_join_table :assets, :general_ledger_accounts
    
    # and index it for mysql    
    add_index :assets_general_ledger_accounts,   [:asset_id, :general_ledger_account_id], :name => :assets_general_ledger_accounts_idx1
    
  end
end
