require 'rails_helper'

describe "expenditures/_documents.html.haml", :type => :view do
  before(:each) do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:expenditure, create(:expenditure))
  end

  it 'no comments' do
    render

    expect(rendered).to have_content('There are no documents for this CapEx.')
  end
  it 'new document' do
    render

    expect(rendered).to have_field('document_document')
    expect(rendered).to have_field('document_description')
  end
end
