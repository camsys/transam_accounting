require 'rails_helper'

describe "grants/_actions.html.haml", :type => :view do
  it 'actions', :skip do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:grant, create(:grant))
    render

    expect(rendered).to have_link('Update this grant')
    expect(rendered).to have_link('Remove this grant')
  end
end
