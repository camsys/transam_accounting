require 'rails_helper'

describe "general_ledger_accounts/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:ledger_account, create(:general_ledger_account))
    render

    expect(rendered).to have_link('Update this general ledger account')
  end
end
