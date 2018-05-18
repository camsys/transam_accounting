require 'rails_helper'

describe "vendors/_vendor_to_date.html.haml", :type => :view do
  it 'expenditures of a vendor', :skip do
    test_vendor = create(:vendor)
    create(:expenditure, :vendor => test_vendor, :amount => 233)
    assign(:vendor, test_vendor)
    render

    expect(rendered).to have_content(1)
    expect(rendered).to have_content('$233')
  end
end
