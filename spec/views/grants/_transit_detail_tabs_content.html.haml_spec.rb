require 'rails_helper'

describe "grants/_transit_detail_tabs_content.html.haml", :type => :view do
  it 'no assets' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:grant, create(:grant))
    assign(:assets, [])
    render

    expect(rendered).to have_content('There are no assets associated with this grant.')
  end
end
