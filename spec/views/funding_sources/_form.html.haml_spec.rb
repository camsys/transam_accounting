require 'rails_helper'

describe "funding_sources/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:funding_source, FundingSource.new)
    render

    expect(rendered).to have_field('funding_source_name')
    expect(rendered).to have_field('funding_source_funding_source_type_id')
    expect(rendered).to have_field('funding_source_external_id')
    expect(rendered).to have_field('funding_source_description')
    expect(rendered).to have_field('funding_source_formula_fund')
    expect(rendered).to have_field('funding_source_discretionary_fund')
    expect(rendered).to have_field('funding_source_match_required')
  end
end
