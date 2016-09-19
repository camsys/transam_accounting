require 'rails_helper'

describe "grants/_documents.html.haml", :type => :view do
  it 'no documents' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:grant, create(:grant))
    render

    expect(rendered).to have_content('There are no documents for this grant.')
    expect(rendered).to have_field('document_document')
    expect(rendered).to have_field('document_description')
  end
end
