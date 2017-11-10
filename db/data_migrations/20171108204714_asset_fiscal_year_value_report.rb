class AssetFiscalYearValueReport < ActiveRecord::DataMigration
  def up
    Report.create!({
         :active => 1,
         :report_type => ReportType.find_by(name: "Inventory Report"),
         :name => 'Asset Value Report by FY',
         :class_name => "AssetFiscalYearValueReport",
         :view_name => "generic_table_with_subreports",
         :show_in_nav => 1,
         :show_in_dashboard => 1,
         :printable => true,
         :exportable => true,
         :roles => 'guest,user,manager',
         :description => 'Displays a report of asset values in GL by FY.',
         :chart_type => '',
         :chart_options => ""
     }) if Report.find_by(class_name: "AssetFiscalYearValueReport").nil?
  end

  def down
    Report.find_by(class_name: "AssetFiscalYearValueReport").destroy
  end
end