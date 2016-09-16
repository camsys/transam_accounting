require 'rails_helper'

describe "funding_sources/_index_actions.html.haml", :type => :view do
  it 'actions' do
    render

    expect(rendered).to have_field('funding_source_type_id')
  end
end
