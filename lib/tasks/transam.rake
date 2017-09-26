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

  desc 'add expenditure asset_type'
  task add_expenditure_asset_type: :environment do

    a = AssetType.new(name: 'Expenditures', class_name: 'Expenditure', display_icon_name: 'fa fa-cogs', map_icon_name: 'blueIcon', description: 'Expenditures', active: true)
    a.save!

    PolicyAssetTypeRule.create!(policy_id: Policy.where('parent_id IS NULL').pluck(:id).first, asset_type_id: a.id, service_life_calculation_type_id: 1, replacement_cost_calculation_type_id: 1, annual_inflation_rate: 1.1, pcnt_residual_value: 0)
  end

  desc "cleanup all GLA/grant data for testing"
  task cleanup_gla_grant_data: :environment do
    # cleanup asset data
    GrantPurchase.delete_all
    Asset.update_all(general_ledger_account_id: nil)

    # cleanup policy data
    PolicyAssetSubtypeRule.update_all(general_ledger_account_id: nil)

    Grant.destroy_all
    GeneralLedgerAccount.destroy_all

    # reload organization GLA's to COA
    OrganizationGeneralLedgerAccount.all.each do |general_gla|
        ChartOfAccount.all.each do |chart|
          chart.general_ledger_accounts.create!(general_ledger_account_type: general_gla.general_ledger_account_type, general_ledger_account_subtype: general_gla.general_ledger_account_subtype, account_number: general_gla.account_number, name: general_gla.name)
        end
    end
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

  desc ""

end
