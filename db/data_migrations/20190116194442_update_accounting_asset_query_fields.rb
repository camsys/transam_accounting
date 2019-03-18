class UpdateAccountingAssetQueryFields < ActiveRecord::DataMigration
  def up
    asso_table = QueryAssociationClass.find_by(table_name: 'funding_sources')
    if asso_table
      asso_table.update display_field_name: 'name'
    end
  end
end