class AddGeneralLedgerReports < ActiveRecord::DataMigration
  def up
    reports = [
        {
            :active => 1,
            :belongs_to => 'report_type',
            :type => "GL/Accounting Report",
            :name => 'Net Book Value Report',
            :class_name => "AssetValueReport",
            :view_name => "generic_table_with_subreports",
            :show_in_nav => 1,
            :show_in_dashboard => 1,
            :printable => true,
            :exportable => true,
            :roles => 'guest,user,manager',
            :description => 'Displays a report of asset net book values.',
            :chart_type => '',
            :chart_options => ""
        },
        {
            :active => 1,
            :belongs_to => 'report_type',
            :type => "GL/Accounting Report",
            :name => 'Gross Asset Value Report',
            :class_name => "GrossAssetValueReport",
            :view_name => "generic_table_with_subreports",
            :show_in_nav => 1,
            :show_in_dashboard => 1,
            :printable => true,
            :exportable => true,
            :roles => 'guest,user,manager',
            :description => 'Displays a report of asset gross values.',
            :chart_type => '',
            :chart_options => ""
        },
        {
            :active => 1,
            :belongs_to => 'report_type',
            :type => "GL/Accounting Report",
            :name => 'Accumulated Depreciation Report',
            :class_name => "AssetAccumulatedDepreciationReport",
            :view_name => "generic_table_with_subreports",
            :show_in_nav => 1,
            :show_in_dashboard => 1,
            :printable => true,
            :exportable => true,
            :roles => 'guest,user,manager',
            :description => 'Displays a report of asset book values.',
            :chart_type => '',
            :chart_options => ""
        },
        {
            :active => 1,
            :belongs_to => 'report_type',
            :type => "GL/Accounting Report",
            :name => 'Gain/Loss on Disposition Report',
            :class_name => "AssetDispositionGainLossReport",
            :view_name => "generic_table_with_subreports",
            :show_in_nav => 1,
            :show_in_dashboard => 1,
            :printable => true,
            :exportable => true,
            :roles => 'guest,user,manager',
            :description => 'Displays a report of asset book values.',
            :chart_type => '',
            :chart_options => ""
        },
    ]

    reports.each do |row|
      if Report.find_by(class_name: row[:class_name]).nil?
        x = Report.new(row.except(:belongs_to, :type))
        x.report_type = ReportType.where(:name => row[:type]).first
        x.save!
      else
        x = Report.find_by(class_name: row[:class_name])
        x.update!(row.except(:belongs_to, :type))
      end
    end
  end
end