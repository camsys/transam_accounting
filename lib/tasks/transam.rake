namespace :transam do
  desc "Updates the book value of every asset."
  task update_book_value: :environment do
    Asset.all.each do |a|
      a.update_book_value
    end
  end

  desc "Runs the ScheduledDepreciationUpdateJob"
  task scheduled_depreciation_update_job: :environment do
    job = ScheduledDepreciationUpdateJob.new
    job.perform
  end

  task create_bucket_types: :environment do
    formula_bucket_type = FundingBucketType.new(:active => 1, :name => 'Formula', :description => 'Formula Bucket')
    existing_bucket_type = FundingBucketType.new(:active => 1, :name => 'Existing Grant', :description => 'Existing Grant')
    grant_application_bucket_type = FundingBucketType.new(:active => 1, :name => 'Fund', :description => 'Fund')

    formula_bucket_type.save
    existing_bucket_type.save
    grant_application_bucket_type.save
  end


  desc "create chart of account for orgs"
  task create_chart_of_accounts: :environment do
    ChartOfAccount.create!(Organization.pluck(:id).map{|o|{organization_id: o}})
  end
end
