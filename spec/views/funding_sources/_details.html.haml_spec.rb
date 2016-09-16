require 'rails_helper'

describe "funding_sources/_details.html.haml", :type => :view do
  it 'info' do
    test_fund = create(:funding_source)
    assign(:funding_source, test_fund)
    assign(:grants, [])
    render

    expect(rendered).to have_content(test_fund.description)
  end
end
