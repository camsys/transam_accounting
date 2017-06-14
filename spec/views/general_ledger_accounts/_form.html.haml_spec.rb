require 'rails_helper'

describe "general_ledger_accounts/_form.html.haml", :skip, :type => :view do
  it 'fields' do
    assign(:ledger_account, GeneralLedgerAccount.new)
    render

    expect(rendered).to have_field('general_ledger_account_general_ledger_account_type_id')
    expect(rendered).to have_field('general_ledger_account_account_number')
    expect(rendered).to have_field('general_ledger_account_name')
  end
end
