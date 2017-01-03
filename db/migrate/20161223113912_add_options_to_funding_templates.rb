class AddOptionsToFundingTemplates < ActiveRecord::Migration

  def change
    unless column_exists? :funding_templates, :create_multiple_buckets_for_agency_year
      add_column :funding_templates, :create_multiple_buckets_for_agency_year, :boolean, null: false, after: :transfer_only
    end
    unless column_exists? :funding_templates, :create_multiple_agencies
      add_column :funding_templates, :create_multiple_agencies, :boolean, null: false, after: :transfer_only
    end
  end

end