require 'rails_helper'

# Rspec for TransamAccountingVendor module
# TransamAccountingVendor extends associations of a vendor

RSpec.describe Vendor, :type => :model do

  let(:test_vendor) { create(:vendor) }

  it 'has many expenditures' do
    expect(test_vendor).to have_many(:expenditures)
  end
  it '.expenditures_ytd' do
    old_expenditure = create(:expenditure, :expense_date => Date.today - 2.years, :vendor => test_vendor)
    expenditure_this_yr = create(:expenditure, :vendor => test_vendor)

    expect(test_vendor.expenditures_ytd).not_to include(old_expenditure)
    expect(test_vendor.expenditures_ytd).to include(expenditure_this_yr)
  end
end
