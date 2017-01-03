class AddNameToFundingBuckets < ActiveRecord::Migration

  def change
    unless column_exists? :funding_buckets, :name
      add_column :funding_buckets, :name, :string, null: false, after: :fiscal_year
    end
  end

end