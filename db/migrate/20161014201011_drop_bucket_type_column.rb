
class DropBucketTypeColumn< ActiveRecord::Migration
  def change
    remove_column :funding_buckets, :bucket_type_id
  end
end
