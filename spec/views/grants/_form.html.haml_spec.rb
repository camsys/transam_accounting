require 'rails_helper'

describe "grants/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:grant, Grant.new)
    assign(:organization_list, [1,2])
    render

    expect(rendered).to have_field('grant_organization_id')
    expect(rendered).to have_field('grant_fy_year')
    expect(rendered).to have_field('grant_sourceable_id')
    expect(rendered).to have_field('grant_amount')
  end
end
