require 'rails_helper'

describe "assets/_accounting_asset_info_detail.html.haml", :type => :view do
  it 'book value' do
    render 'assets/accounting_asset_info_detail', :asset => create(:buslike_asset, :book_value => 7890)

    expect(rendered).to have_content('$7,890')
  end
end
