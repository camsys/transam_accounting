require 'rails_helper'

describe "expenditures/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:expenditure, Expenditure.new)
    assign(:asset, create(:buslike_asset))
    test_org = create(:organization)
    create(:chart_of_account, :organization => test_org)
    assign(:organization, test_org)
    render

    expect(rendered).to have_xpath('//input[@id="asset_key"]')
    expect(rendered).to have_field('expenditure_description')
    expect(rendered).to have_field('expenditure_expense_type_id')
    expect(rendered).to have_field('expenditure_amount')
    expect(rendered).to have_field('expenditure_expense_date')
    expect(rendered).to have_field('expenditure_vendor_id')
    expect(rendered).to have_field('expenditure_general_ledger_account_id')
    expect(rendered).to have_field('expenditure_grant_id')
    expect(rendered).to have_field('expenditure_pcnt_from_grant')
  end
end
