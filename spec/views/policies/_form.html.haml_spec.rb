require 'rails_helper'

describe "policies/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:policy, Policy.new)
    render

    expect(rendered).to have_field('policy_description')
    expect(rendered).to have_field('policy_condition_estimation_type_id')
    expect(rendered).to have_field('policy_condition_threshold')
    expect(rendered).to have_field('policy_depreciation_calculation_type_id')
    expect(rendered).to have_field('policy_depreciation_interval_type_id')
  end
end
