require 'rails_helper'

describe "general_ledger_accounts/_index_table.html.haml", :type => :view do
  it 'info' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_gla = create(:general_ledger_account)
    render 'general_ledger_accounts/index_table', :gl_accounts => [test_gla]

    expect(rendered).to have_content(test_gla.name)
    expect(rendered).to have_content(test_gla.account_number)
  end
end
