require 'rails_helper'

describe "grants/_accounting_detail_tabs_content.html.haml", :type => :view do
  it 'no expenditures' do
    assign(:organization, create(:organization))
    assign(:grant, create(:grant))
    render

    expect(rendered).to have_content('There are no CapEx associated with this grant.')
  end
end
