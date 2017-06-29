class CreateOrganizationGeneralLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :organization_general_ledger_accounts do |t|
      t.string :name
      t.string :account_number
      t.references :general_ledger_account_type, index: {name: 'org_general_ledger_account_general_ledger_account_type_idx'}
      t.boolean :grant_budget_specific
      t.boolean :active
    end
  end
end
