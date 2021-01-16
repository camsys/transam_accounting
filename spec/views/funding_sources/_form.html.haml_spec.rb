require 'rails_helper'

describe "funding_sources/_form.html.haml", :type => :view do
  it 'fields' do

    allow(controller).to receive(:current_user).and_return(create(:admin))

    assign(:funding_source, FundingSource.new)
    render

    expect(rendered).to have_field('funding_source_name')
    expect(rendered).to have_field('funding_source_funding_source_type_id')
    expect(rendered).to have_field('funding_source_description')
    expect(rendered).to have_field('fund_formula')
    expect(rendered).to have_field('fund_discretionary')
    expect(rendered).to have_field('funding_source_match_required')
  end
end
