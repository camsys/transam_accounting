require 'rails_helper'

describe "general_ledger_accounts/_index_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:params).and_return({controller: 'general_ledger_accounts'})
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:chart_of_accounts, create(:chart_of_account))
    render

    expect(rendered).to have_link('GL Mappings')
  end
end
