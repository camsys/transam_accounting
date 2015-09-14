require 'rails_helper'

RSpec.describe GeneralLedgerAccountsController, :type => :controller do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_user) { create(:admin) }

  before(:each) do
    User.destroy_all
    test_user.organizations << test_user.organization
    test_user.save!
    sign_in test_user
  end

  it 'GET index' do
    test_chart = create(:chart_of_account, :organization => test_user.organization)
    test_gla = create(:general_ledger_account, :chart_of_account => test_chart)
    get :index

    expect(assigns(:chart_of_accounts)).to eq(test_chart)
    expect(assigns(:ledger_accounts)).to include(test_gla)
  end

  it 'GET show' do
    test_chart = create(:chart_of_account, :organization => test_user.organization)
    test_gla = create(:general_ledger_account, :chart_of_account => test_chart)
    get :show, :id => test_gla.object_key

    expect(assigns(:ledger_account)).to eq(test_gla)
  end

  it 'GET new' do
    get :new

    expect(assigns(:ledger_account).to_json).to eq(GeneralLedgerAccount.new.to_json)
  end

  it 'GET edit' do
    test_chart = create(:chart_of_account, :organization => test_user.organization)
    test_gla = create(:general_ledger_account, :chart_of_account => test_chart)
    get :edit, :id => test_gla.object_key

    expect(assigns(:ledger_account)).to eq(test_gla)
  end

  it 'POST create' do
    test_chart = create(:chart_of_account, :organization => test_user.organization)

    post :create, :general_ledger_account => attributes_for(:general_ledger_account, :chart_of_account_id => nil, :account_number => 'GLA-123123')

    expect(assigns(:ledger_account).chart_of_account).to eq(test_chart)
    expect(assigns(:ledger_account).account_number).to eq('GLA-123123')
  end

  it 'POST update' do
    test_chart = create(:chart_of_account, :organization => test_user.organization)
    test_gla = create(:general_ledger_account, :chart_of_account => test_chart)
    post :update, :id => test_gla.object_key, :general_ledger_account => {:name => 'Test GLA2'}
    test_gla.reload

    expect(test_gla.name).to eq('Test GLA2')
  end

  it 'DELETE destroy' do
    test_chart = create(:chart_of_account, :organization => test_user.organization)
    test_gla = create(:general_ledger_account, :chart_of_account => test_chart)
    delete :destroy, :id => test_gla.object_key

    expect(GeneralLedgerAccount.find_by(:object_key => test_gla.object_key)).to be nil
  end
end
