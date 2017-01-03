class RemoveUnusedColumnsFundingSources < ActiveRecord::Migration
  def change
    remove_column :funding_sources, :state_administered_federal_fund
    remove_column :funding_sources, :bond_fund
    remove_column :funding_sources, :non_committed_fund
    remove_column :funding_sources, :contracted_fund
    remove_column :funding_sources, :state_match_required
    remove_column :funding_sources, :local_match_required
    remove_column :funding_sources, :rural_providers
    remove_column :funding_sources, :urban_providers
    remove_column :funding_sources, :shared_ride_providers
    remove_column :funding_sources, :inter_city_bus_providers
    remove_column :funding_sources, :inter_city_rail_providers
  end
end
