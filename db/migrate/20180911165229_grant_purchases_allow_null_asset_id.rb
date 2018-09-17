class GrantPurchasesAllowNullAssetId < ActiveRecord::Migration[5.2]
  def change
    change_column_null :grant_purchases, :asset_id, true
  end
end
