class CreateGeneralLedgerMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :general_ledger_mappings do |t|
      t.string :object_key, null: false, limit: 12
      t.references :chart_of_account, index: true
      t.references :asset_subtype, index: true
      t.references :asset_account, index: true
      t.references :depr_expense_account, index: true
      t.references :accumulated_depr_account, index: true
      t.references :gain_loss_account, index: true

      t.timestamps
    end
  end
end
