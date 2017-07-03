require 'rails_helper'

describe "general_ledger_accounts/_grants.html.haml", :type => :view do
  it 'no gla budgets' do
    render 'general_ledger_accounts/gla_budgets', :gla_budgets => []

    expect(rendered).to have_content('There are no associated GLA budgets.')
  end

  it 'list' do
    test_budget = create(:grant_budget, grant: create(:grant), general_ledger_account: create(:general_ledger_account))
    render 'general_ledger_accounts/gla_budgets', :gla_budgets => [test_budget]

    expect(rendered).to have_content(test_budget.general_ledger_account.to_s)
    expect(rendered).to have_content(test_budget.sourceable.to_s)
    expect(rendered).to have_content('$10,000')
  end
end
