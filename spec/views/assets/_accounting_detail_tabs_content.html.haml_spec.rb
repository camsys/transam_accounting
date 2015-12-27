require 'rails_helper'

describe "assets/_accounting_detail_tabs_content.html.haml", :type => :view do

  class TestOrg < Organization
    def get_policy
      return Policy.find_by_organization_id(self.id)
    end
  end

  it 'no expenditures' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    test_asset = create(:buslike_asset)
    assign(:asset, test_asset)
    create(:policy, :organization => test_asset.organization)
    assign(:expenditure, Expenditure.new)
    assign(:organization, test_asset.organization)
    render

    expect(rendered).to have_content('There are no CapEx associated with this asset.')
  end
end
