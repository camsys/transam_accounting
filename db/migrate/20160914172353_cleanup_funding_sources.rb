class CleanupFundingSources < ActiveRecord::Migration
  def change
    add_column :funding_sources, :details, :text, after: :description
    add_column :funding_sources, :inflation_rate, :float, before: :state_match_required
    add_column :funding_sources, :life_in_years, :integer, after: :inflation_rate
    add_column :funding_sources, :fy_start, :integer, after: :local_match_required
    add_column :funding_sources, :fy_end, :integer, after: :fy_start
    rename_column :funding_sources, :federal_match_required, :match_required


  end
end
