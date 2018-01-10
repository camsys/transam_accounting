class AddExtendedUsefulLifeMonthsExpenditures < ActiveRecord::Migration
  def change
    add_column :expenditures, :extended_useful_life_months, :integer, after: :amount
  end
end
