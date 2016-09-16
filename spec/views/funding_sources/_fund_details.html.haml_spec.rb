require 'rails_helper'

describe "funding_sources/_fund_details.html.haml", :type => :view do
  it 'info' do
    test_fund = create(:funding_source, :state_match_required => 25, :local_match_required => 30)
    assign(:funding_source, test_fund)
    render

    expect(rendered).to have_content('25.000%')
    expect(rendered).to have_content('30.000%')
  end
end
