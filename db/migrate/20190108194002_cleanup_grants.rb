class CleanupGrants < ActiveRecord::Migration[5.2]
  def change
    add_column :grants, :state, :string, after: :sourceable_type
    add_column :grants, :created_by_user_id, :integer, after: :state
    add_column :grants, :updated_by_user_id, :integer, after: :created_by_user_id
    rename_column :grants, :name, :grant_num
    rename_column :grants, :organization_id, :owner_id
    add_reference :grants, :contributor, after: :owner_id
    add_column :grants, :other_contributor, :string, after: :contributor_id
    add_column :grants, :legislative_authorization, :string, after: :amount
    add_column :grants, :award_date, :date, after: :fy_year
    add_column :grants, :over_allocation_allowed, :boolean, after: :sourceable_type



    create_table :grant_amendments do |t|
      t.string :object_key, null: false, limit: 12
      t.references :grant, foreign_key: true
      t.string :amendment_num
      t.string :grant_num
      t.text :comments
      t.integer :created_by_user_id

      t.timestamps
    end
  end
end
