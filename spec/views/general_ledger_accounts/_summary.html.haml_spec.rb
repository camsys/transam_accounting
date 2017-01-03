require 'rails_helper'

describe "general_ledger_accounts/_summary.html.haml", :type => :view do
  it 'info' do
    test_gla = create(:general_ledger_account)
    render 'general_ledger_accounts/summary', :ledger_account => test_gla

    expect(rendered).to have_content(test_gla.name)
    expect(rendered).to have_content(test_gla.account_number)
    expect(rendered).to have_content(test_gla.general_ledger_account_type.to_s)
  end
end
