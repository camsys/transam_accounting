require 'rails_helper'

describe "grants/_comments.html.haml", :type => :view do
  it 'no comments' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:grant, create(:grant))
    render

    expect(rendered).to have_content('There are no comments for this grant.')
    expect(rendered).to have_field('comment_comment')
  end
end
