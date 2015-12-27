require 'rails_helper'

describe "assets/_accounting_asset_dt_columns.html.haml", :type => :view do
  it 'info' do
    render 'assets/accounting_asset_dt_columns', :a => create(:buslike_asset, :book_value => 54321)

    expect(rendered).to have_content('$54,321')
  end
end
