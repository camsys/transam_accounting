#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob


  def execute_job(asset)



    just_disposed_and_transferred = !asset.disposed? && asset.disposition_updates.last.try(:disposition_type_id) == 2

    asset.record_disposition
    if(just_disposed_and_transferred)
      new_asset = asset.transfer asset.organization_id
      send_asset_transferred_message new_asset
    end


    if (asset.respond_to? :general_ledger_accounts) && GrantPurchase.sourceable_type == 'Grant' && asset.general_ledger_accounts.count > 0

      disposal_account = ChartOfAccount.find_by(organization_id: asset.organization_id).general_ledger_accounts.find_by(general_ledger_account_subtype: GeneralLedgerAccountSubtype.find_by(name: 'Disposal Account'))

      amount_not_ledgered = asset.purchase_cost-asset.book_value # temp variable for tracking rounding errors
      asset.grant_purchases.order(:pcnt_purchase_cost).each_with_index do |grant_purchase, idx|
        unless idx+1 == asset.grant_purchases.count
          amount = ((asset.purchase_cost-asset.book_value) * grant_purchase.pcnt_purchase_cost / 100.0).round
          amount_not_ledgered -= amount
        else
          amount = amount_not_ledgered
        end

        asset.general_ledger_accounts.accumulated_depreciation_accounts.find_by(grant_id: grant_purchase.sourceable_id).general_ledger_account_entries.create!(sourceable_type: 'Asset', sourceable_id: asset.id, description: "#{asset.organization}: #{asset.to_s} Disposal #{asset.disposition_date}", amount: amount)
      end


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
