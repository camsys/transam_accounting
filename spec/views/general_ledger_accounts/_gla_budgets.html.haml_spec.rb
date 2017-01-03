require 'rails_helper'

describe "general_ledger_accounts/_gla_budgets.html.haml", :type => :view do
  it 'no gla budgets' do
    render 'general_ledger_accounts/gla_budgets', :gla_budgets => []

    expect(rendered).to have_content('There are no gla budgets associated with this account.')
  end

  it 'list' do
    test_budget = create(:grant_budget)
    render 'general_ledger_accounts/gla_budgets', :gla_budgets => [test_budget]

    expect(rendered).to have_content(test_budget.grant.grant_number)
    expect(rendered).to have_content(test_budget.grant.funding_source.to_s)
    expect(rendered).to have_content('$50,000')
  end
end
