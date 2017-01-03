require 'rails_helper'

describe "funding_sources/_grants_table.html.haml", :type => :view do
  it 'no grants' do
    render 'funding_sources/grants_table', :grants => []

    expect(rendered).to have_content('There are no grants for this fund.')
  end
  it 'list' do
    test_grant = create(:grant)
    render 'funding_sources/grants_table', :grants => Grant.where(:object_key => test_grant.object_key)

    expect(rendered).to have_content(test_grant.funding_source.to_s)
    expect(rendered).to have_content(test_grant.grant_number)
    expect(rendered).to have_content('$50,000')
    expect(rendered).to have_content(test_grant.organization.short_name)
  end
end
