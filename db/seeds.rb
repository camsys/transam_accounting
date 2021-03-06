#encoding: utf-8

# determine if we are using postgres or mysql
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql2')
is_sqlite =  (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3')

#------------------------------------------------------------------------------
#
# Lookup Tables
#
# These are the lookup tables for TransAM Accounting Module
#
#------------------------------------------------------------------------------

puts "======= Processing TransAM Accounting Lookup Tables  ======="

asset_event_types = [
    {:active => 1, :name => 'Initial book value', :class_name => 'BookValueUpdateEvent', :job_name => 'AssetBookValueUpdateJob', :display_icon_name => 'fa fa-hourglass-start', :description => 'Initial Book Value Update'},
    {:active => 1, :name => 'Book value', :class_name => 'BookValueUpdateEvent', :job_name => 'AssetBookValueUpdateJob', :display_icon_name => 'fa fa-hourglass-end', :description => 'Book Value Update'}
]

activities = [
    { name: 'Automated Depreciation Expense',
      description: 'Calculate book value of assets at end of depreciation interval',
      show_in_dashboard: false,
      system_activity: true,
      frequency_quantity: 1,
      frequency_type_id: 3,
      execution_time: '22:01',
      job_name: 'AssetDepreciationExpenseUpdateJob',
      active: true }
]

funding_source_types = [
    {:active => 1, :name => 'Federal',  :description => 'Federal Funding Source'},
    {:active => 1, :name => 'State',    :description => 'State Funding Source'},
    {:active => 1, :name => 'Local',    :description => 'Local Funding Source'},
    {:active => 1, :name => 'Agency',    :description => 'Agency Funding Source'}
]


general_ledger_account_types = [
  {:active => 1, :name => 'Asset Account',       :description => 'Accounts representing different types of resources owned or controlled by the business.'},
  {:active => 1, :name => 'Liability Account',   :description => 'Accounts representing different types of obligations for the business.'},
  {:active => 1, :name => 'Equity Account',      :description => 'Accounts representing the residual equity the business.'},
  {:active => 1, :name => 'Revenue Account',     :description => 'Accounts representing the businesses gross earnings.'},
  {:active => 1, :name => 'Expense Account',     :description => 'Accounts representing the expenditures for the business.'}
]

general_ledger_account_subtypes = [
  {:active => 1, :general_ledger_account_type_id => 1, :name => 'Fixed Asset Account', :description => 'Accounts representing transit assets owned or controlled by the business.'},
  {:active => 1, :general_ledger_account_type_id => 1, :name => 'Grant Funding Account', :description => 'Accounts representing grant funding.'},
  {:active => 1, :general_ledger_account_type_id => 1, :name => 'Accumulated Depreciation Account', :description => 'Accounts representing asset accumulated depreciation.'},
  {:active => 1, :general_ledger_account_type_id => 5, :name => 'Depreciation Expense Account', :description => 'Accounts representing asset depreciation expense.'},
  {:active => 1, :general_ledger_account_type_id => 1, :name => 'Disposal Account', :description => 'Accounts representing asset disposal.'}
]

depreciation_calculation_types = [
  {:active => 1, :name => 'Straight Line',      :class_name => "StraightLineDepreciationCalculator",      :description => 'Calculates the value of an asset using a straight line depreciation method.'},
  {:active => 1, :name => 'Declining Balance',  :class_name => "DecliningBalanceDepreciationCalculator",  :description => 'Calculates the value of an asset using a double declining balance depreciation method.'}
]

depreciation_interval_types = [
  {:active => 1, :name => 'Annually', :description => 'Depreciation calculated annually at the end of the fiscal year.', :months => 12},
  {:active => 1, :name => 'Quarterly', :description => 'Depreciation calculated quarterly.', :months => 3},
  {:active => 1, :name => 'Monthly', :description => 'Depreciation calculated monthly.', :months => 1}
]

report_types = [
  {:active => 0, :name => 'GL/Accounting Report', :description => 'GL/Accounting Report', :display_icon_name => 'fa fa-book'}
]
system_config_extensions = [
    {engine_name: 'accounting', class_name: 'RehabilitationUpdateEvent', extension_name: 'TransamGlAccountableAssetEvent', active: true},
    {engine_name: 'accounting', class_name: 'AssetsController', extension_name: 'TransamAccountingAssetsController', active: true},
    #{engine_name: 'accounting', class_name: 'Organization', extension_name: 'TransamAccountable', active: true}, comment out temporarily as all orgs dont have COA
    {engine_name: 'accounting', class_name: 'Policy', extension_name: 'TransamAccountingPolicy', active: true},
    {engine_name: 'accounting', class_name: 'Vendor', extension_name: 'TransamAccountingVendor', active: true},
    {engine_name: 'accounting', class_name: 'TransamAsset', extension_name: 'TransamValuable', active: true}

]

roles = [
    {name: 'grant_manager', privilege: true, show_in_user_mgmt: true, weight: 11}
]

lookup_tables = %w{ funding_source_types general_ledger_account_types general_ledger_account_subtypes depreciation_calculation_types depreciation_interval_types}
merge_tables = %w{ asset_event_types activities report_types system_config_extensions roles}

lookup_tables.each do |table_name|
  puts "  Loading #{table_name}"
  if is_mysql
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
  elsif is_sqlite
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
  else
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
  end
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end

merge_tables.each do |table_name|
  puts "  Merging #{table_name}"
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row.except(:belongs_to, :type))
    x.save!
  end
end

reports = [
    {
        :active => 1,
        :belongs_to => 'report_type',
        :type => "Inventory Report",
        :name => 'Asset Funding Source Report',
        :class_name => "AssetFundingSourceReport",
        :view_name => "grp_header_table_with_subreports",
        :show_in_nav => 1,
        :show_in_dashboard => 0,
        :printable => true,
        :exportable => true,
        :roles => 'guest,user,manager',
        :description => 'Displays asset purchase info.',
        :chart_type => '',
        :chart_options => ""
    },
    {
        :active => 0,
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
        :active => 0,
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
        :active => 0,
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
        :active => 0,
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
    }
]

table_name = 'reports'
puts "  Merging #{table_name}"
data = eval(table_name)
data.each do |row|
  x = Report.new(row.except(:belongs_to, :type))
  x.report_type = ReportType.where(:name => row[:type]).first
  x.save!
end

# asset query seeds
require_relative File.join('asset_query_seeds')
