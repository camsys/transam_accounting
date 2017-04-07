require 'rails_helper'

include FiscalYear

RSpec.describe GrantsController, :type => :controller do

  let(:test_user)  { create(:admin) }
  let(:test_grant) { create(:grant) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  describe 'fiscal years' do
    it 'no min fy' do
      get :index

      expect(subject.send(:fiscal_year_range)).to eq(get_fiscal_years)
    end
    it 'no num forecasting years' do
      subject.instance_variable_set(:@organization, test_user.organization)
      test_grant.update!(:fy_year => 2010, :organization => subject.current_user.organization)

      expect(subject.send(:fiscal_year_range)).to eq(get_fiscal_years(Date.new(2010,7,1),18))
    end
    it 'num forecast years' do
      subject.instance_variable_set(:@organization, test_user.organization)
      test_grant.update!(:fy_year => 2010, :organization => subject.current_user.organization)

      expect(subject.send(:fiscal_year_range, 5)).to eq(get_fiscal_years(Date.new(2010,7,1),5))
    end
  end

  describe 'GET index' do
    let(:test_asset) { create(:buslike_asset, :organization => subject.current_user.organization) }
    it 'all' do
      test_grant.update!(:organization => subject.current_user.organization)
      get :index

      expect(assigns(:grants)).to include(test_grant)
    end
    it 'funding source' do
      test_funding_source = test_grant.funding_source
      test_grant.update!(:organization => subject.current_user.organization)
      get :index, :funding_source_id => test_funding_source.id

      expect(assigns(:funding_source_id)).to eq(test_funding_source.id)
      expect(assigns(:grants)).to include(test_grant)

      get :index, :funding_source_id => test_funding_source.id + 1
      expect(assigns(:grants)).not_to include(test_grant)
    end
    it 'fiscal year' do
      test_fy = test_grant.fy_year
      test_grant.update!(:organization => subject.current_user.organization)
      get :index, :fiscal_year => test_fy

      expect(assigns(:fiscal_year)).to eq(test_fy)
      expect(assigns(:grants)).to include(test_grant)

      get :index, :funding_source_id => test_fy + 1
      expect(assigns(:grants)).not_to include(test_grant)
    end
  end

  it 'GET summary_info' do
    get :summary_info, :id => test_grant.object_key, :format => :json

    expect(assigns(:grant)).to eq(test_grant)
  end

  # TODO
  it 'GET show', :skip do
    test_asset = create(:buslike_asset, :organization => subject.current_user.organization)
    create(:grant_purchase, :asset => test_asset, :grant => test_grant)
    get :show, :id => test_grant.object_key

    expect(assigns(:grant)).to eq(test_grant)
    expect(assigns(:assets)).to include(test_asset)
  end

  it 'GET new' do
    get :new

    expect(assigns(:grant).to_json).to eq(Grant.new.to_json)
  end

  it 'GET edit' do
    get :edit, :id => test_grant.object_key

    expect(assigns(:grant)).to eq(test_grant)
  end

  it 'POST create' do
    post :create, :grant => {:fy_year => Date.today.year+1, :grant_number => 'GRANT-XX-123456', :amount => 55555}

    expect(assigns(:grant).fy_year).to eq(Date.today.year+1)
    expect(assigns(:grant).grant_number).to eq('GRANT-XX-123456')
    expect(assigns(:grant).amount).to eq(55555)
  end

  it 'PUT update' do
    put :update, :id => test_grant.object_key, :grant => {:amount => 54321}

    expect(assigns(:grant).amount).to eq(54321)
  end

  it 'DELETE destroy' do
    delete :destroy, :id => test_grant.object_key

    expect(Grant.find_by(:object_key => test_grant.object_key)).to be nil
  end
end
