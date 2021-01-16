require 'rails_helper'

describe "funding_sources/_index_actions.html.haml", :type => :view do

  let(:test_admin) {create(:admin)}
  it 'actions' do
    allow(controller).to receive(:current_user).and_return(test_admin)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_admin))
    assign(:funding_source, FundingSource.new)
    render

    # these filters have been removed as a part of the table UI refresh, and this check is no longer needed
    # expect(rendered).to have_field('funding_source_type_id')
  end
end
