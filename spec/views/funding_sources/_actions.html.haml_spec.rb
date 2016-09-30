require 'rails_helper'

describe "funding_sources/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:funding_source, create(:funding_source))
    render

    expect(rendered).to have_link('Update this funding program')
    expect(rendered).to have_link('Remove this funding program')
  end
end
