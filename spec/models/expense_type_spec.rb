require 'rails_helper'

RSpec.describe ExpenseType, :type => :model do

  let(:test_type) { create(:expense_type) }

  it '.to_s' do
    expect(test_type.to_s).to eq(test_type.name)
  end
end
