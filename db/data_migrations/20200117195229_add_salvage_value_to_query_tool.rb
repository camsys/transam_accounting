class AddSalvageValueToQueryTool < ActiveRecord::DataMigration
  def up
    qf = QueryField.find_or_create_by(
        name: 'salvage_value',
        label: 'Salvage Value',
        query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (Depreciation)'),
        filter_type: 'numeric'
    )
    qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'transam_assets')
  end
end