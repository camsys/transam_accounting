require 'rails_helper'

describe "grants/_gla_table.html.haml", :type => :view do
  it 'no gla budgets' do
    render 'grants/gla_table', :gla_budgets => []

    expect(rendered).to have_content('There are no associated GLA budgets.')
  end

  it 'list' do
    test_budget = create(:grant_budget)
    render 'grants/gla_table', :gla_budgets => [test_budget]

    expect(rendered).to have_content(test_budget.general_ledger_account.name)
    expect(rendered).to have_content(test_budget.general_ledger_account.account_number)
    expect(rendered).to have_content(test_budget.general_ledger_account.general_ledger_account_type.name)
    expect(rendered).to have_content('$10,000')
  end
end
