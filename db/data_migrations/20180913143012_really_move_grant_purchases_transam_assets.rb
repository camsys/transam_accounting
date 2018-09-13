class ReallyMoveGrantPurchasesTransamAssets < ActiveRecord::DataMigration
  def up
    GrantPurchase.all.each do |gp|
      gp.update_columns(transam_asset_id: TransitAsset.find_by(asset_id: gp.asset_id).try(:transam_asset).try(:id))
    end
  end
end