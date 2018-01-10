require 'rails_helper'

describe "shared/_financial_nav.html.haml", :type => :view do
  it 'links', :skip do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))

    test_org = create(:organization)
    test_chart = create(:chart_of_account, :organization => test_org)
    test_gla = create(:general_ledger_account, :chart_of_account => test_chart)
    assign(:organization, test_org)
    test_grant = create(:grant, :organization => test_org)
    test_expense_type = create(:expense_type, :organization => test_org)
    test_expenditure = create(:expenditure, :organization => test_org, :expense_type => test_expense_type)
    render

    expect(rendered).to have_link('Chart of Accounts')
    expect(rendered).to have_link(GeneralLedgerAccountType.first.to_s)
    expect(rendered).to have_link('Grants')
    expect(rendered).to have_link(test_grant.funding_source.to_s)
    expect(rendered).to have_link('Add Grant')
    expect(rendered).to have_link('CapEx')
    expect(rendered).to have_link(test_expense_type.to_s)
    expect(rendered).to have_link('Add CapEx')
    expect(rendered).to have_link('Vendors')
  end
end
