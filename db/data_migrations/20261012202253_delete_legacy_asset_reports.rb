# frozen_string_literal: true

class DeleteLegacyAssetReports < ActiveRecord::DataMigration
  def up
    Report.where(class_name: ['AssetValueReport', 'GrossAssetValueReport', 'AssetFiscalYearValueReport']).destroy_all
  end
end