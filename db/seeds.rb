#encoding: utf-8

# determine if we are using postgres or mysql
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'mysql2')
is_sqlite =  (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3')

#------------------------------------------------------------------------------
#
# Lookup Tables
#
# These are the lookup tables for TransAM Accounting Module
#
#------------------------------------------------------------------------------

puts "======= Processing TransAM Accounting Lookup Tables  ======="

funding_source_types = [
    {:active => 1, :name => 'Federal',  :description => 'Federal Funding Source'},
    {:active => 1, :name => 'State',    :description => 'State Funding Source'},
    {:active => 1, :name => 'Local',    :description => 'Local Funding Source'},
    {:active => 1, :name => 'Agency',    :description => 'Agency Funding Source'}
]


general_ledger_account_types = [
  {:active => 1, :name => 'Asset Account',      :description => 'Accounts representing different types of resources owned or controlled by the business.'},
  {:active => 1, :name => 'Liability Account',  :description => 'Accounts representing different types of obligations for the business.'},
  {:active => 1, :name => 'Equity Account',     :description => 'Accounts representing the residual equity the business.'},
  {:active => 1, :name => 'Revenue Account',    :description => 'Accounts representing the businesses gross earnings.'},
  {:active => 1, :name => 'Expense Account',    :description => 'Accounts representing the expenditures for the business.'},
  {:active => 1, :name => 'Contra Account',     :description => 'Accounts representing negative balances due to accu,ulated depreciation etc.'}
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


lookup_tables = %w{ funding_source_types general_ledger_account_types depreciation_calculation_types depreciation_interval_types}

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
