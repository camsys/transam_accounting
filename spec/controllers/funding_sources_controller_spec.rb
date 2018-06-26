require 'rails_helper'

RSpec.describe FundingSourcesController, :type => :controller do

  let(:test_user)  { create(:admin) }
  let(:test_fund) { create(:funding_source) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    test_fund.save!
    get :index, params: {:funding_source_type_id => 1}

    expect(assigns(:funding_source_type_id)).to eq(1)
    expect(assigns(:funding_sources)).to include(test_fund)
  end
  it 'GET details' do
    get :details, params: {:funding_source_id => test_fund.id, :format => :json}

    expect(assigns(:funding_source)).to eq(test_fund)
  end
  it 'GET show' do
    get :show, params: {:id => test_fund.object_key}
    #test_grant = create(:grant, :sourceable => test_fund, :organization => subject.current_user.organization)

    expect(assigns(:funding_source)).to eq(test_fund)
    #expect(assigns(:grants)).to include(test_grant)
  end
  it 'GET new' do
    get :new

    expect(assigns(:funding_source).to_json).to eq(FundingSource.new.to_json)
  end
  it 'GET edit' do
    get :edit, params: {:id => test_fund.object_key}

    expect(assigns(:funding_source)).to eq(test_fund)
  end
  it 'GET create' do
    post :create, params:{:funding_source => {:name => 'new funding source', :description => 'test description 2', :funding_source_type_id => 1}}

    expect(assigns(:funding_source).name).to eq('new funding source')
    expect(assigns(:funding_source).description).to eq('test description 2')
    expect(assigns(:funding_source).funding_source_type_id).to eq(1)
  end
  it 'GET update' do
    put :update, params: {:id => test_fund.object_key, :funding_source => {:description => 'new description'}}
    test_fund.reload

    expect(test_fund.description).to eq('new description')
  end
  it 'DELETE destroy' do
    delete :destroy, params: {:id => test_fund.object_key}

    expect(FundingSource.find_by(:object_key => test_fund.object_key)).to be nil
  end

  it '.check_for_cancel', :skip do
  end
end
