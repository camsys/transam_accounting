require 'rails_helper'

describe "funding_sources/_details.html.haml", :type => :view do
  it 'info' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    test_fund = create(:funding_source)
    assign(:funding_source, test_fund)
    assign(:grants, [])
    assign(:organization_list, Organization.ids)
    render

    expect(rendered).to have_content(test_fund.description)
  end
end
