class AddFieldsGrantPurchases < ActiveRecord::Migration[5.2]
  def change
    add_column :grant_purchases, :expense_tag, :string, after: :pcnt_purchase_cost
    add_column :grant_purchases, :other_sourceable, :string, after: :sourceable_type
  end
end
