class AddFundingSourcesOrganizations < ActiveRecord::Migration[5.2]
  def change
    unless table_exists? :funding_sources_organizations
      create_table :funding_sources_organizations, :id => false do |t|
        t.references :funding_source,       index: true
        t.references :organization,           index: true
      end
    end
  end
end
