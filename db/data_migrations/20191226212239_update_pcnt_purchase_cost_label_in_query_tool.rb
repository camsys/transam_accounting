class UpdatePcntPurchaseCostLabelInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'pcnt_purchase_cost')&.update!(label: '% Funding')
  end
end