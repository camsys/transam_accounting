require 'rails_helper'

describe "vendors/_accounting_detail_tabs_content.html.haml", :type => :view do
  it 'no expenditures' do
    assign(:vendor, create(:vendor))
    render

    expect(rendered).to have_content('There are no CapEx associated with this vendor.')
  end
end
