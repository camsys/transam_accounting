require 'rails_helper'

describe "funding_sources/_index_table.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_fund = create(:funding_source)
    render 'funding_sources/index_table', :funding_sources => [test_fund]

    expect(rendered).to have_content(test_fund.object_key)
    expect(rendered).to have_content(test_fund.name)
    expect(rendered).to have_content(test_fund.funding_source_type.to_s)
  end
end
