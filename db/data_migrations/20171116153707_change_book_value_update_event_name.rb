class ChangeBookValueUpdateEventName < ActiveRecord::DataMigration
  def up
    asset_event_type = AssetEventType.find_by(class_name: 'BookValueUpdateEvent')
    if asset_event_type.present?
      asset_event_type.update!(name: 'Adjust Book Value')
    end
  end
end