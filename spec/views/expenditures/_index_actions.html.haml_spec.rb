require 'rails_helper'

describe "expenditures/_index_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_chart = create(:chart_of_account)
    create(:general_ledger_account, :chart_of_account => test_chart)
    assign(:organization, test_chart.organization)
    assign(:fiscal_years, [Date.today.year, Date.today.year+1])
    render

    expect(rendered).to have_link('Add CapEx')
    expect(rendered).to have_field('general_ledger_account_id')
    expect(rendered).to have_field('type')
    expect(rendered).to have_field('vendor_id')
    expect(rendered).to have_field('fiscal_year')
  end
end
