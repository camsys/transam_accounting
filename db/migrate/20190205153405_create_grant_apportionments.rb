class CreateGrantApportionments < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_apportionments do |t|
      t.string :object_key, null: false, limit: 12
      t.references :grant
      t.references :sourceable, polymorphic: true
      t.string :name
      t.integer :fy_year
      t.integer :amount
      t.integer :created_by_user_id
      t.integer :updated_by_user_id

      t.timestamps
    end
  end
end
