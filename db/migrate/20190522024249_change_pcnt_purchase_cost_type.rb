class ChangePcntPurchaseCostType < ActiveRecord::Migration[5.2]
  def change
    change_column :grant_purchases, :pcnt_purchase_cost, :float
  end
end
