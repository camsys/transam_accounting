class RenameBucketTypeToFundingBucketType < ActiveRecord::Migration
  def change
    rename_table :bucket_types, :funding_bucket_types
  end
end
