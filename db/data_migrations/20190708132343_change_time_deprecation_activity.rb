class ChangeTimeDeprecationActivity < ActiveRecord::DataMigration
  def up
    Activity.find_by(job_name: 'AssetDepreciationExpenseUpdateJob').update!(execution_time: '22:01')
  end
end