#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob


  def execute_job(asset)



    # If the asset has already been transferred then this is an update to the disposition and we don't want to create another asset.
    asset_event_type = AssetEventType.where(:class_name => 'DispositionUpdateEvent').first
    asset_event = AssetEvent.where(:asset_id => asset.id, :asset_event_type_id => asset_event_type.id).last
    disposition_type = DispositionType.where(:id => asset_event.disposition_type_id).first

    asset_already_transferred = asset.disposed disposition_type

    asset.record_disposition
    if(!asset_already_transferred && asset_event.disposition_type_id == 2)
      new_asset = asset.transfer asset_event.organization_id
      send_asset_transferred_message new_asset
    end


    if (asset.respond_to? :general_ledger_accounts) && asset.general_ledger_accounts.count > 0

      disposal_account = ChartOfAccount.find_by(organization_id: asset.organization_id).general_ledger_accounts.find_by(general_ledger_account_subtype: GeneralLedgerAccountSubtype.find_by(name: 'Disposal Account'))

      asset.general_ledger_accounts.find_by(general_ledger_account_subtype: GeneralLedgerAccountSubtype.find_by(name: 'Accumulated Depreciation Account')).general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} Disposal #{asset.disposition_date}", amount: asset.purchase_cost-asset.book_value)


      if asset.book_value > 0
        disposal_account.general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} Disposal #{asset.disposition_date}", amount: asset.book_value)
      end

      asset.general_ledger_account.general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} Disposal #{asset.disposition_date}", amount: -asset.purchase_cost)

      disposition_event = asset.disposition_updates.last
      if disposition_event.sale_proceeds > 0
        disposal_account.general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} Disposal #{asset.disposition_date}", amount: -disposition_event.sale_proceeds)
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
