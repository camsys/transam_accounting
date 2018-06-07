class CreateDepreciationEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :depreciation_entries do |t|
      t.string :object_key, null: false, limit: 12
      t.references :asset, index: true
      t.date :event_date
      t.string :description
      t.integer :book_value

      t.timestamps
    end

    create_table :depreciation_entries_general_ledger_account_entries do |t|
      t.integer :depreciation_entry_id, index: {name: 'depr_entry_idx'}
      t.integer :general_ledger_account_entry_id, index: {name: 'gl_entry_idx'}
    end

    add_column :asset_events, :book_value, :integer, after: :sales_proceeds

    asset_event_types = [
        {:active => 1, :name => 'Book value', :class_name => 'BookValueUpdateEvent', :job_name => 'AssetBookValueUpdateJob', :display_icon_name => 'fa fa-hourglass-end', :description => 'Book Value Update'}
    ]

    asset_event_types.each do |type|
      if AssetEventType.find_by(class_name: type[:class_name]).nil?
        AssetEventType.create!(type)
      end
    end
  end
end
