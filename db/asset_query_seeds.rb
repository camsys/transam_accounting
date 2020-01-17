### Load asset query configurations
puts "======= Loading core asset query configurations ======="

# transam_assets table
grant_purchase_table = QueryAssetClass.find_or_create_by(table_name: 'grant_purchases', transam_assets_join: "left join grant_purchases on grant_purchases.transam_asset_id = transam_assets.id and grant_purchases.sourceable_type = 'FundingSource'")
grant_purchase_grants_table = QueryAssetClass.find_or_create_by(table_name: 'grant_purchases_grants', transam_assets_join: "left join grant_purchases AS grant_purchases_grants on grant_purchases_grants.transam_asset_id = transam_assets.id and grant_purchases_grants.sourceable_type = 'Grant'")


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
      label: '% Funding',
      filter_type: 'numeric'
    },
    {
      name: 'amount',
      label: 'Amount (Funding)',
      filter_type: 'numeric'
    }
  ],
  'Procurement & Purchase': [
    {
      name: 'sourceable_id',
      label: 'Grant #',
      filter_type: 'multi_select',
      pairs_with: 'other_sourceable',
      association: {
        table_name: 'grants',
        display_field_name: 'grant_num'
      }
    },
    {
      name: 'other_sourceable',
      label: 'Grant # (Other)',
      filter_type: 'text',
      hidden: true
    },
    {
      name: 'amount',
      label: 'Amount (Grant)',
      filter_type: 'numeric'
    },
    {
      name: 'pcnt_purchase_cost',
      label: '% Funding (Grant)',
      filter_type: 'numeric'
    },
    {
      name: 'expense_tag',
      label: 'Expense ID',
      filter_type: 'text'
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
    category_name.to_s == 'Funding' ? qf.query_asset_classes << grant_purchase_table : qf.query_asset_classes << grant_purchase_grants_table
  end
end

# create field for salvage_value on transam_assets
qf = QueryField.find_or_create_by(
  name: 'salvage_value',
  label: 'Salvage Value',
  query_category: QueryCategory.find_or_create_by(name: 'Life Cycle (Depreciation)'),
  filter_type: 'numeric'
)
qf.query_asset_classes << QueryAssetClass.find_by(table_name: 'transam_assets')