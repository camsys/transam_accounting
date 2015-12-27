require 'rails_helper'

describe "expenditures/_comments.html.haml", :type => :view do
  before(:each) do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:expenditure, create(:expenditure))
  end

  it 'no comments' do
    render

    expect(rendered).to have_content('There are no comments for this CapEx.')
  end
  it 'new comment' do
    render

    expect(rendered).to have_field('comment_comment')
  end
end
