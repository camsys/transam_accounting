class RemoveAllOrganizationsColumnsAndAddSqlQueryColumn < ActiveRecord::Migration
  def change
    unless column_exists? :funding_templates, :query_string
      add_column :funding_templates, :query_string, :text, after: :match_required
    end

    if column_exists? :funding_templates, :all_organizations

      all_templates = FundingTemplate.all

      all_templates.each { |t|
        if t.all_organizations
          t.query_string = TransitOperator.all.to_sql
          t.save
        end
      }

      remove_column :funding_templates, :all_organizations
    end


  end
end
