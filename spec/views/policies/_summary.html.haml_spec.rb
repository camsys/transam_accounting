require 'rails_helper'

describe "policies/_summary.html.haml", :type => :view do
  it 'info' do
    test_policy = create(:policy, :parent => create(:policy))
    assign(:policy, test_policy)
    render

    expect(rendered).to have_content(test_policy.organization.name)
    expect(rendered).to have_content(test_policy.description)
    expect(rendered).to have_link(test_policy.parent.name.to_s)
    expect(rendered).to have_content(ConditionEstimationType.first.to_s)
    expect(rendered).to have_content(test_policy.condition_threshold)
    expect(rendered).to have_content(DepreciationCalculationType.first.to_s)
    expect(rendered).to have_content(DepreciationIntervalType.first.to_s)
  end
end
