class AddExternalIdToExpenditures < ActiveRecord::Migration
  def change
    add_column :expenditures, :external_id, :string, :limit => 32, :after => :expense_type_id
  end
end
