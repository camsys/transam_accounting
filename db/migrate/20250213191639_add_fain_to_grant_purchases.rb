class AddFainToGrantPurchases < ActiveRecord::Migration[5.2]
  def change
    add_column :grant_purchases, :fain, :string
  end
end
