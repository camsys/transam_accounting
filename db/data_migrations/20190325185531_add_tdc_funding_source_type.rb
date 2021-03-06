class AddTdcFundingSourceType < ActiveRecord::DataMigration
  def up
    tdc_type = FundingSourceType.create!(name: 'TDC', description: 'Transportation Development Credits', active: false)
    FundingSource.create!(name: 'TDC', description: 'Transportation Development Credits', funding_source_type: tdc_type, match_required: 20, discretionary_fund: true, formula_fund: false)
  end
end