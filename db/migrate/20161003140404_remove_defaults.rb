class RemoveDefaults < ActiveRecord::Migration
  def change
    change_column_default :issues, :issue_status_type_id, nil
    change_column_default :funding_sources, :description, nil
    drop_table :fta_funding_source_types if table_exists? :fta_funding_source_types
  end
end
