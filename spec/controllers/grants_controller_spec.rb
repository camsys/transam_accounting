require 'rails_helper'

include FiscalYear

RSpec.describe GrantsController, :type => :controller do

  let(:test_user)  { create(:admin) }
  let(:test_grant) { create(:grant, :owner => subject.current_user.organization) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.viewable_organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  describe 'GET index' do
    let(:test_asset) { create(:buslike_asset, :organization => subject.current_user.organization) }
    it 'all' do
      get :index

      expect(assigns(:grants)).to include(test_grant)
    end
    it 'global_sourceable' do
      test_funding_source = test_grant.sourceable
      get :index, params: {:global_sourceable => test_funding_source.to_global_id}

      expect(assigns(:sourceable)).to eq(test_funding_source)
      expect(assigns(:grants)).to include(test_grant)

      get :index, params: {:global_sourceable => create(:funding_source).to_global_id}
      expect(assigns(:grants)).not_to include(test_grant)
    end
    it 'fiscal year' do
      test_fy = test_grant.fy_year
      get :index, params: {:fiscal_year => test_fy}

      expect(assigns(:fiscal_year)).to eq(test_fy)
      expect(assigns(:grants)).to include(test_grant)

      get :index, params: {:fiscal_year => test_fy + 1}
      expect(assigns(:grants)).not_to include(test_grant)
    end
  end

  it 'GET summary_info' do
    get :summary_info, params: {:id => test_grant.object_key, :format => :json}

    expect(assigns(:grant)).to eq(test_grant)
  end

  # TODO
  it 'GET show', :skip do
    test_asset = create(:buslike_asset, :organization => subject.current_user.organization)
    create(:grant_purchase, :asset => test_asset, :grant => test_grant)
    get :show, params: {:id => test_grant.object_key}

    expect(assigns(:grant)).to eq(test_grant)
    expect(assigns(:assets)).to include(test_asset)
  end

  it 'GET new' do
    get :new

    expect(assigns(:grant).to_json).to eq(Grant.new.to_json)
  end


  it 'POST create' do
    post :create, params: {:grant => {:fy_year => Date.today.year+1, :amount => 55555}}

    expect(assigns(:grant).fy_year).to eq(Date.today.year+1)
    expect(assigns(:grant).amount).to eq(55555)
  end

  it 'PUT update' do
    put :update, params: {:id => test_grant.object_key, :grant => {:amount => 54321}}

    expect(assigns(:grant).amount).to eq(54321)
  end

  it 'DELETE destroy' do
    delete :destroy, params: {:id => test_grant.object_key}

    expect(Grant.find_by(:object_key => test_grant.object_key)).to be nil
  end
end
