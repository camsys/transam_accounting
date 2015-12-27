require 'rails_helper'

describe "expenditures/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:expenditure, create(:expenditure))
    render

    expect(rendered).to have_link('Update this CapEx')
    expect(rendered).to have_link('Remove this CapEx')
  end
end
