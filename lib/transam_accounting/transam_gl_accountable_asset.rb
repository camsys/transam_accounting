module TransamGlAccountableAsset
  #------------------------------------------------------------------------------
  #
  # Accountable
  #
  # Injects methods and associations for managing general ledger accounts for an asset
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    # ----------------------------------------------------
    # Callbacks
    # ----------------------------------------------------
    after_save        :update_general_ledger_accounts, :if => Proc.new{ GrantPurchase.sourceable_type == 'Grant' }

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    belongs_to :general_ledger_account

    has_and_belongs_to_many :general_ledger_accounts, :foreign_key => :asset_id

    # each asset was purchased using one or more grants
    has_many    :grant_purchases,  :foreign_key => :asset_id, :dependent => :destroy, :inverse_of => :asset

    # Allow the form to submit grant purchases
    accepts_nested_attributes_for :grant_purchases, :reject_if => :all_blank, :allow_destroy => true

    # ----------------------------------------------------
    # Validations
    # ----------------------------------------------------



  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  module ClassMethods
    def self.allowable_params
      [
          :general_ledger_account_id,
          :grant_purchases_attributes => [GrantPurchase.allowable_params]
      ]
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  protected

  def update_general_ledger_accounts

    if self.general_ledger_account.nil?
      return true
    end
    # ----------------------------------------------------------------------------------- #
    # Possible GLAs an asset can be associated with:
    # -- fixed asset account (main association: general_ledger_account_id)
    # -- grant funding
    # -- accumulated depr
    # -- depreciation expensep

    # -- gain/loss on disposal
    # -- cash
    # ----------------------------------------------------------------------------------- #


    # --------------------------- fixed asset account ------------------------------------
    # just checks if the fixed asset GLA changes
    # does not check the entries if the GLA is the same - done later
    asset_gla = self.general_ledger_account
    old_fixed_asset_acct = general_ledger_accounts.fixed_asset_accounts.first

    if old_fixed_asset_acct && old_fixed_asset_acct != asset_gla
      general_ledger_accounts.delete(old_fixed_asset_acct)
      old_fixed_asset_acct.general_ledger_account_entries.where(sourceable_type: 'Asset', sourceable_id: self.id).each do |gla_entry|
        reversal_entry = gla_entry.dup
        reversal_entry.description = "[Reversed] "+reversal_entry.description
        reversal_entry.amount = gla_entry.amount * (-1)
        reversal_entry.object_key = nil
        reversal_entry.generate_object_key(:object_key)
        reversal_entry.save!
      end
    else
      general_ledger_accounts << asset_gla
    end

    # ------------------------------------------------------------------------------------

    # ------------------------- grant funding accounts -----------------------------------

    # delete any grant funding accounts not used
    # does not check the entries - done later
    unused = general_ledger_accounts.grant_funding_accounts.pluck(:grant_id) - grant_purchases.where(sourceable_type: 'Grant').pluck(:sourceable_id)
    unused.each do |unused_id|
      acct = general_ledger_accounts.grant_funding_accounts.find_by(grant_id: unused_id)
      general_ledger_accounts.delete(acct)
      acct.general_ledger_account_entries.where(sourceable_type: 'Asset', sourceable_id: self.id).each do |gla_entry|
        reversal_entry = gla_entry.dup
        reversal_entry.amount = gla_entry.amount * (-1)
        reversal_entry.description = "[Reversed] "+reversal_entry.description
        reversal_entry.object_key = nil
        reversal_entry.generate_object_key(:object_key)
        reversal_entry.save!
      end
    end

    #have an array to store entries to reverse after updating grant purchases
    reverse_entries = []
    included_reversed_asset_entries = false #temp

    amount_not_ledgered = purchase_cost # temp variable for tracking rounding errors
    grant_purchases.order(:pcnt_purchase_cost).each_with_index do |gp, idx|
      funding_gla = organization.general_ledger_accounts.grant_funding_accounts.find_by(grant: gp.sourceable, account_number: "#{asset_gla.account_number}-#{gp.sourceable}")
      if funding_gla.nil?
        funding_gla = GeneralLedgerAccount.create!(chart_of_account_id: asset_gla.chart_of_account_id, general_ledger_account_type_id: GeneralLedgerAccountType.find_by(name: 'Asset Account').id, general_ledger_account_subtype_id: GeneralLedgerAccountSubtype.find_by(name: 'Grant Funding Account').id, account_number: "#{asset_gla.account_number}-#{gp.sourceable}", name: "#{asset_gla.name} #{gp.sourceable} Funding", grant_id: gp.sourceable_id)
      end
      general_ledger_accounts << funding_gla

      unless idx+1==grant_purchases.count
        amount = (purchase_cost * gp.pcnt_purchase_cost / 100.0).round
        amount_not_ledgered -= amount
      else
        amount = amount_not_ledgered
      end

      # check fixed asset account entries
      asset_gla_entry = asset_gla.general_ledger_account_entries.find_by(sourceable_type: 'Asset', sourceable_id: self.id, amount: amount)
      if asset_gla_entry.nil?
        unless included_reversed_asset_entries
          reverse_entries << asset_gla.general_ledger_account_entries.where(sourceable_type: 'Asset', sourceable_id: self.id).ids

          included_reversed_asset_entries = true
        end
        asset_gla.general_ledger_account_entries.create!(description: "#{organization}: #{self}", sourceable_type: 'Asset', sourceable_id: self.id, amount: amount)
      end

      # check grant funding entries
      grant_gla_entry = funding_gla.general_ledger_account_entries.find_by(sourceable_type: 'Asset', sourceable_id: self.id, amount: -amount)
      if grant_gla_entry.nil?
        reverse_entries << funding_gla.general_ledger_account_entries.where(sourceable_type: 'Asset', sourceable_id: self.id).ids
        funding_gla.general_ledger_account_entries.create!(description: "#{organization}: #{self}", sourceable_type: 'Asset', sourceable_id: self.id, amount: -amount)
      end

    end

    reverse_entries = reverse_entries.flatten!
    GeneralLedgerAccountEntry.where(id: reverse_entries).each do |entry|
      reversal_entry = entry.dup
      reversal_entry.amount = entry.amount * (-1)
      reversal_entry.description = "[Reversed] "+reversal_entry.description
      reversal_entry.object_key = nil
      reversal_entry.generate_object_key(:object_key)
      reversal_entry.save!
    end

    # ------------------------------------------------------------------------------------





  end

end
