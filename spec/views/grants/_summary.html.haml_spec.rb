require 'rails_helper'

describe "grants/_summary.html.haml", :type => :view do
  it 'info' do
    test_grant = create(:grant, :fy_year => 2015)
    assign(:grant, test_grant)
    render

    expect(rendered).to have_content(test_grant.funding_source.to_s)
    expect(rendered).to have_content('FY 15-16')
    expect(rendered).to have_content('$50,000')
  end
end
