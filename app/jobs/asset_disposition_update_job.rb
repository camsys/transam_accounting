#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob



  def execute_job(asset)
    disposition_event = asset.disposition_updates.last
    just_disposed_and_transferred = !asset.disposed? && disposition_event.try(:disposition_type_id) == 2

    Rails.application.config.asset_base_class_name.constantize.find_by(object_key: asset.object_key).update_columns(disposition_date: disposition_event.try(:event_date))

    if(just_disposed_and_transferred)
      new_asset = asset.transfer disposition_event.organization_id
      send_asset_transferred_message new_asset
    end

    gl_mapping = asset.general_ledger_mapping
    if gl_mapping.present?

      amount = asset.adjusted_cost_basis-asset.book_value # temp variable for tracking rounding errors
      gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: amount, asset: asset)

      if asset.book_value > 0
        gl_mapping.gain_loss_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: asset.book_value, asset: asset)
      end

      gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: -asset.adjusted_cost_basis, asset: asset)

      disposition_event = asset.disposition_updates.last
      if disposition_event.sales_proceeds.to_i > 0
        gl_mapping.gain_loss_account.general_ledger_account_entries.create!(event_date: asset.disposition_date, description: " Disposal: #{asset.asset_path}", amount: -disposition_event.sales_proceeds, asset: asset)
      end
    end

  end

  def prepare
    Rails.logger.debug "Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

  def send_asset_transferred_message asset

    transit_managers = get_users_for_organization asset.organization

    event_url = Rails.application.routes.url_helpers.new_inventory_path asset

    transfer_notification = Notification.create(text: "A new asset has been transferred to you. Please update the asset.", link: event_url, notifiable_type: 'Organization', notifiable_id: asset.organization_id )

    transit_managers.each do |usr|
      UserNotification.create(notification: transfer_notification, user: usr)
    end

  end

  # TODO there is probably a better way
  def get_users_for_organization organization
    user_role = Role.find_by(:name => 'transit_manager')

    unless user_role.nil?
      users = organization.users_with_role user_role.name
    end

    return users || []
  end

end
