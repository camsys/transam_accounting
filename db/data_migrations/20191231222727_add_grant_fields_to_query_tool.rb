class AddGrantFieldsToQueryTool < ActiveRecord::DataMigration
  def up
    grant_purchase_grants_table = QueryAssetClass.find_or_create_by(table_name: 'grant_purchases', transam_assets_join: "left join grant_purchases on grant_purchases.transam_asset_id = transam_assets.id and grant_purchases.sourceable_type = 'Grant'")

    fields = [
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

    fields.each do |f|
      if f[:association]
        qac = QueryAssociationClass.find_or_create_by(f[:association])
      end
      qf = QueryField.find_or_create_by(
          name: f[:name],
          label: f[:label],
          query_category: QueryCategory.find_or_create_by(name: 'Procurement & Purchase'),
          query_association_class_id: qac.try(:id),
          filter_type: f[:filter_type],
          auto_show: f[:auto_show],
          hidden: f[:hidden],
          pairs_with: f[:pairs_with]
      )
      qf.query_asset_classes << grant_purchase_grants_table
      qf.save!
    end
  end
end