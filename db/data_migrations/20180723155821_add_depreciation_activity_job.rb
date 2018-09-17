class AddDepreciationActivityJob < ActiveRecord::DataMigration
  def up
    activities = [
        { name: 'Automated Depreciation Expense',
          description: 'Calculate book value of assets at end of depreciation interval',
          show_in_dashboard: false,
          system_activity: true,
          frequency_quantity: 1,
          frequency_type_id: 3,
          execution_time: '00:01',
          job_name: 'AssetDepreciationExpenseUpdateJob',
          active: true }
    ]

    activities.each do |activity|
      Activity.create!(activity)
    end
  end
end