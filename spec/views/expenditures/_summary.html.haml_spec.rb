require 'rails_helper'

describe "expenditures/_summary.html.haml", :type => :view do
  it 'info' do
    test_expenditure = create(:expenditure)
    assign(:organization, create(:organization))
    render 'expenditures/summary', :expenditure => test_expenditure

    expect(rendered).to have_content(test_expenditure.description)
    expect(rendered).to have_content('$0')
    expect(rendered).to have_content(test_expenditure.expense_type.to_s)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
  end
end
