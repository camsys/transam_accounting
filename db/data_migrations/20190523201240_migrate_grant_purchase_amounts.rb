class MigrateGrantPurchaseAmounts < ActiveRecord::DataMigration
  def up
    GrantPurchase.all.each do |gp|
      if gp.pcnt_purchase_cost && gp.transam_asset&.purchase_cost 
        gp.update(amount: (gp.transam_asset&.purchase_cost * gp.pcnt_purchase_cost / 100).to_i)
      end
    end
  end
end