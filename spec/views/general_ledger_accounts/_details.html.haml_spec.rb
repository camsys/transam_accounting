require 'rails_helper'

describe "general_ledger_accounts/_details.html.haml", :type => :view do
  it 'if no info' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:ledger_account, create(:general_ledger_account))
    assign(:organization, create(:organization))
    assign(:expenditure, Expenditure.new)
    render

    expect(rendered).to have_content('There are no associated GLA budgets.')
    expect(rendered).to have_content('There are no CapEx associated with this general ledger account.')
  end
end
