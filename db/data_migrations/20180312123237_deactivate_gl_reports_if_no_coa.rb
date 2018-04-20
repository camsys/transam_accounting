class DeactivateGlReportsIfNoCoa < ActiveRecord::DataMigration
  def up
    has_coa = ChartOfAccount.count > 0

    report_type = ReportType.find_by(name: "GL/Accounting Report")
    report_type.update!(active: has_coa)

    report_type.reports.update_all(active: has_coa)

  end
end