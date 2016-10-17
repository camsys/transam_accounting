class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :bucket_types do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.boolean :active, null: false
    end

    create_table :buckets do |t|
      t.string    :object_key, index: true, limit: 12, null: false
      t.integer   :funding_template_id, null: false
      t.integer   :fiscal_year, null: false
      t.integer   :bucket_type_id, null: false
      t.decimal   :budget_amount, precision: 15, scale: 2, null: false
      t.decimal   :budget_committed, precision: 15, scale: 2, null: false
      t.integer   :owner_id, null: true
      t.string    :description, null: true
      t.boolean   :active, null: false
      t.integer   :created_by_id, null: false
      t.datetime  :created_on
      t.integer   :updated_by_id, null: false
      t.datetime  :updated_on
    end


    formula_bucket_type = FundingBucketType.new(:active => 1, :name => 'Formula', :description => 'Formula Bucket')
    existing_bucket_type = FundingBucketType.new(:active => 1, :name => 'Existing Grant', :description => 'Existing Grant')
    grant_application_bucket_type = FundingBucketType.new(:active => 1, :name => 'Grant Application', :description => 'Grant Application Bucket')

    formula_bucket_type.save
    existing_bucket_type.save
    grant_application_bucket_type.save

  end
end
