class AddExtendedUsefulLifeMonthsExpenditures < ActiveRecord::Migration[4.2]
  def change
    add_column :expenditures, :extended_useful_life_months, :integer, after: :amount
  end
end
