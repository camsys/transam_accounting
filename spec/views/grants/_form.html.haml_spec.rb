require 'rails_helper'

describe "grants/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:grant, Grant.new)
    render

    expect(rendered).to have_field('grant_funding_source_id')
    expect(rendered).to have_field('grant_fy_year')
    expect(rendered).to have_field('grant_grant_number')
    expect(rendered).to have_field('grant_amount')
  end
end
