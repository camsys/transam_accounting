class AddAccountingReportType < ActiveRecord::DataMigration
  def up
    report_type = ReportType.find_or_initialize_by(name: 'GL/Accounting Report')
    report_type.description = report_type.name
    report_type.display_icon_name = 'fa fa-book'
    report_type.active = true
    report_type.save!

    Report.where(class_name: ['AssetValueReport', 'AssetFiscalYearValueReport']).update_all(report_type_id: report_type.id)
  end


end