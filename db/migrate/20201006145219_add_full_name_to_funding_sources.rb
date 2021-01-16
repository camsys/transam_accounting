class AddFullNameToFundingSources < ActiveRecord::Migration[5.2]
  def change
    add_column :funding_sources, :full_name, :string
  end
end
