### Load asset query configurations
puts "======= Loading core asset query configurations ======="

# transam_assets table
grant_purchase_table = QueryAssetClass.find_or_create_by(table_name: 'grant_purchases', transam_assets_join: "left join grant_purchases on grant_purchases.transam_asset_id = transam_assets.id and grant_purchases.sourceable_type = 'FundingSource'")

# Query Category and fields
category_fields = {
  'Funding': [
    {
      name: 'sourceable_id',
      label: 'Program',
      filter_type: 'multi_select',
      association: {
        table_name: 'funding_sources',
        display_field_name: 'name'
      }
    },
    {
      name: 'pcnt_purchase_cost',
      label: '%',
      filter_type: 'numeric'
    }
  ]
}

category_fields.each do |category_name, fields|
  qc = QueryCategory.find_or_create_by(name: category_name)
  fields.each do |field|
    if field[:association]
      qac = QueryAssociationClass.find_or_create_by(field[:association])
    end
    qf = QueryField.find_or_create_by(
      name: field[:name], 
      label: field[:label], 
      query_category: qc, 
      query_association_class_id: qac.try(:id),
      filter_type: field[:filter_type],
      auto_show: field[:auto_show],
      hidden: field[:hidden],
      pairs_with: field[:pairs_with]
    )
    qf.query_asset_classes << grant_purchase_table
  end
end
