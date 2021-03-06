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

  desc "update general ledger account types"
  task update_general_ledger_account_types: :environment do
    general_ledger_account_types = [
        {:id => 1, :active => 1, :name => 'Asset Account',       :description => 'Accounts representing different types of resources owned or controlled by the business.'},
        {:id => 2, :active => 1, :name => 'Liability Account',   :description => 'Accounts representing different types of obligations for the business.'},
        {:id => 3, :active => 1, :name => 'Equity Account',      :description => 'Accounts representing the residual equity the business.'},
        {:id => 4, :active => 1, :name => 'Revenue Account',     :description => 'Accounts representing the businesses gross earnings.'},
        {:id => 5, :active => 1, :name => 'Expense Account',     :description => 'Accounts representing the expenditures for the business.'}
    ]

    general_ledger_account_subtypes = [
        {:active => 1, :general_ledger_account_type_id => 1, :name => 'Fixed Asset Account', :description => 'Accounts representing transit assets owned or controlled by the business.'},
        {:active => 1, :general_ledger_account_type_id => 1, :name => 'Grant Funding Account', :description => 'Accounts representing grant funding.'},
        {:active => 1, :general_ledger_account_type_id => 1, :name => 'Accumulated Depreciation Account', :description => 'Accounts representing asset accumulated depreciation.'},
        {:active => 1, :general_ledger_account_type_id => 5, :name => 'Depreciation Expense Account', :description => 'Accounts representing asset depreciation expense.'},
        {:active => 1, :general_ledger_account_type_id => 1, :name => 'Disposal Account', :description => 'Accounts representing asset disposal.'}
    ]

    general_ledger_account_types.each do |gla_type|
      GeneralLedgerAccountType.create!(gla_type) if GeneralLedgerAccountType.find_by(name: gla_type[:name]).nil?
    end

    general_ledger_account_subtypes.each do |gla_type|
      GeneralLedgerAccountSubtype.create!(gla_type) if GeneralLedgerAccountSubtype.find_by(name: gla_type[:name]).nil?
    end
  end

  desc "cleanup all GLA/grant data for testing"
  task reload_depr_data: :environment do
    DepreciationEntry.destroy_all

    Asset.update_all(current_depreciation_date: nil)
  end

  desc "Add accounting reports"
  task add_accounting_reports: :environment do
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
            :active => 1,
            :belongs_to => 'report_type',
            :type => "Inventory Report",
            :name => 'Asset Value Report',
            :class_name => "AssetValueReport",
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

  desc "Add GL entries to disposed assets"
  task add_disposition_gl_entries: :environment do
    Asset.disposed.each do |asset|
      asset = Asset.get_typed_asset(asset)
      gl_mapping = asset.general_ledger_mapping
      if gl_mapping.present?

        amount = asset.adjusted_cost_basis-asset.book_value # temp variable for tracking rounding errors
        gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: amount, asset: asset)

        if asset.book_value > 0
          gl_mapping.gain_loss_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: asset.book_value, asset: asset)
        end

        gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: -asset.adjusted_cost_basis, asset: asset)

        disposition_event = asset.disposition_updates.last
        if disposition_event.sales_proceeds > 0
          gl_mapping.gain_loss_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: "Disposal: #{asset.asset_path}", amount: -disposition_event.sales_proceeds, asset: asset)
        end
      end
    end
  end

end
