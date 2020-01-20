class AddDeprUsefulLifeQueryTool < ActiveRecord::DataMigration
  def up
    TransamAsset.operational.each{|asset| asset.update_columns(depreciation_useful_life: asset.expected_useful_life)}

    qf = QueryField.find_or_create_by(
        name: 'depreciation_useful_life',
        label: 'Depreciation Service Life',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (Depreciation)'),
        filter_type: 'numeric'
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'transam_assets')
    qf.save!
  end
end