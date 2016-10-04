class CreateBuckets < ActiveRecord::Migration
  def change
    unless table_exists?('buckets')
      create_table :buckets do |t|
        t.string  :object_key
        t.integer :funding_template_id
        t.integer :fiscal_year
        t.integer :budget_amount
        t.integer :owner_id
        t.string  :description
        t.boolean :active
      end
    end
  end
end
