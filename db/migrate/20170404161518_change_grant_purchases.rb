class ChangeGrantPurchases < ActiveRecord::Migration[4.2]
  def change
    change_table :grant_purchases do |t|
      t.references :sourceable, :polymorphic => true
    end

    remove_column :grant_purchases, :grant_id

  end
end
