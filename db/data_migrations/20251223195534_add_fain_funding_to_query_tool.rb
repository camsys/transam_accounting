# frozen_string_literal: true

class AddFainFundingToQueryTool < ActiveRecord::DataMigration
  def up
    grant_purchase_table = QueryAssetClass.find_or_create_by(table_name: 'grant_purchases', transam_assets_join: "left join grant_purchases on grant_purchases.transam_asset_id = transam_assets.id and grant_purchases.sourceable_type = 'FundingSource'")
    qc = QueryCategory.find_or_create_by(name: 'Funding')
    qf = QueryField.find_or_create_by(name: 'fain', label: 'FAIN', query_category: qc, filter_type: 'text')
    qf.query_asset_classes << grant_purchase_table
    qf.save!
  end
end