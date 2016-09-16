require 'rails_helper'

describe "funding_sources/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:funding_source, FundingSource.new)
    render

    expect(rendered).to have_field('funding_source_name')
    expect(rendered).to have_field('funding_source_funding_source_type_id')
    expect(rendered).to have_field('funding_source_external_id')
    expect(rendered).to have_field('funding_source_description')
    expect(rendered).to have_field('funding_source_state_administered_federal_fund')
    expect(rendered).to have_field('funding_source_bond_fund')
    expect(rendered).to have_field('funding_source_formula_fund')
    expect(rendered).to have_field('funding_source_non_committed_fund')
    expect(rendered).to have_field('funding_source_contracted_fund')
    expect(rendered).to have_field('funding_source_discretionary_fund')
    expect(rendered).to have_field('funding_source_state_match_required')
    expect(rendered).to have_field('funding_source_federal_match_required')
    expect(rendered).to have_field('funding_source_local_match_required')
    expect(rendered).to have_field('funding_source_rural_providers')
    expect(rendered).to have_field('funding_source_urban_providers')
    expect(rendered).to have_field('funding_source_shared_ride_providers')
    expect(rendered).to have_field('funding_source_inter_city_bus_providers')
    expect(rendered).to have_field('funding_source_inter_city_rail_providers')
  end
end
