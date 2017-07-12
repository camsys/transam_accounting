require 'rails_helper'

RSpec.describe ExpendituresController, :skip, :type => :controller do

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
    test_expenditure = create(:expenditure, :organization => subject.current_user.organization)
    get :index

    expect(assigns(:expenditures)).to include(test_expenditure)
  end

  it 'GET show' do
    test_expenditure = create(:expenditure, :organization => subject.current_user.organization)
    get :show, :id => test_expenditure.object_key

    expect(assigns(:expenditure)).to eq(test_expenditure)
  end

  it 'GET new' do
    get :new

    expect(assigns(:expenditure).to_json).to eq(Expenditure.new.to_json)
  end

  it 'GET edit' do
    test_expenditure = create(:expenditure, :organization => subject.current_user.organization)
    get :edit, :id => test_expenditure.object_key

    expect(assigns(:expenditure)).to eq(test_expenditure)
  end

  it 'POST create' do
    post :create, :expenditure => attributes_for(:expenditure, :organization => nil, :description => 'Test Expenditure Description 2', :expense_date => Date.today.strftime('%m/%d/%Y'))

    expect(assigns(:expenditure).organization).to eq(Organization.get_typed_organization(subject.current_user.organization))
    expect(assigns(:expenditure).description).to eq('Test Expenditure Description 2')
  end

  it 'POST update' do
    test_expenditure = create(:expenditure, :organization => subject.current_user.organization)
    post :update, :id => test_expenditure.object_key, :expenditure => {:description => 'Test Expenditure Description 3', :expense_date => Date.today.strftime('%m/%d/%Y')}
    test_expenditure.reload

    expect(test_expenditure.description).to eq('Test Expenditure Description 3')
  end

  it 'DELETE destroy' do
    test_expenditure = create(:expenditure, :organization => subject.current_user.organization)
    delete :destroy, :id => test_expenditure.object_key

    expect(Expenditure.find_by(:object_key => test_expenditure.object_key)).to be nil
  end


end
