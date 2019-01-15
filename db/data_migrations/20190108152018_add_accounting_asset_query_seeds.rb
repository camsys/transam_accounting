class AddAccountingAssetQuerySeeds < ActiveRecord::DataMigration
  def up
    require TransamAccounting::Engine.root.join('db', 'asset_query_seeds.rb')
  end
end