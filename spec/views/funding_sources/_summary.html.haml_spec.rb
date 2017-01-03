require 'rails_helper'

describe "funding_sources/_summary.html.haml", :type => :view do
  it 'list' do
    test_fund = create(:funding_source, :external_id => 'EXT 123')
    assign(:funding_source, test_fund)
    render

    expect(rendered).to have_content(test_fund.external_id)
    expect(rendered).to have_content(test_fund.funding_source_type.to_s)
  end
end
