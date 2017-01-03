require 'rails_helper'

describe "expenditures/_details.html.haml", :type => :view do
  it 'no assets' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:expenditure, create(:expenditure))
    render

    expect(rendered).to have_content('There are no assets associated with this CapEx.')
  end
end
