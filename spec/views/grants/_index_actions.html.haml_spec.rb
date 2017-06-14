require 'rails_helper'

describe "grants/_index_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:fiscal_years, [Date.today.year, Date.today.year+1])
    render

    expect(rendered).to have_link('Add Grant')
    expect(rendered).to have_field('sourceable_id')
    expect(rendered).to have_field('fiscal_year')
  end
end
