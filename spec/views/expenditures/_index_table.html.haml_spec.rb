require 'rails_helper'

describe "expenditures/_index_table.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_expenditure = create(:expenditure)
    render 'expenditures/index_table', :expenditures => Expenditure.where(:object_key => test_expenditure.object_key)

    expect(rendered).to have_content(test_expenditure.object_key)
    expect(rendered).to have_content(test_expenditure.expense_type.to_s)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content(test_expenditure.description)
  end
end
