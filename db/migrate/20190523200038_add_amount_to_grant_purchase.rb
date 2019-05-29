class AddAmountToGrantPurchase < ActiveRecord::Migration[5.2]
  def change
    add_column :grant_purchases, :amount, :integer
  end
end
