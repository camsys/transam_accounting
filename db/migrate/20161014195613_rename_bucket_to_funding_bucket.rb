class RenameBucketToFundingBucket < ActiveRecord::Migration
  def change
    rename_table :buckets, :funding_buckets

  end
end
