module TransamGlAccountableAssetEvent
  #------------------------------------------------------------------------------
  #
  # Accountable
  #
  # Injects methods and associations for managing depreciable assets into an
  # Organization class
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    after_create     :create_depreciation_entry

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    belongs_to :general_ledger_account

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
          :general_ledger_account_id
      ]
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------


  protected

  def create_depreciation_entry
    changed_amount = (self.total_cost - self.total_cost_was.to_i)

    gl_mapping = transam_asset.general_ledger_mapping
    if gl_mapping.present? # check whether this app records GLAs at all

      gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: event_date, description: "Rehab: #{transam_asset.asset_path}", amount: changed_amount, asset: transam_asset)

      if self.general_ledger_account.present?
        self.general_ledger_account.general_ledger_account_entries.create!(event_date: event_date, description: "Rehab: #{transam_asset.asset_path}", amount: -changed_amount, asset: transam_asset)
      end
    end

    transam_asset.depreciation_entries.create!(description: "Rehab: #{self.comments}", book_value: changed_amount, event_date: self.event_date)
    transam_asset.update!(current_depreciation_date: self.event_date)

    transam_asset.depreciation_entries.depreciation_expenses.where('event_date > ?',self.event_date).each do |depr_entry|
      if gl_mapping.present?
        gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Accumulated Depreciation: #{transam_asset.asset_path}", amount: -depr_entry.book_value, asset: transam_asset)

        gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Deprectiation Expense: #{transam_asset.asset_path}", amount: depr_entry.book_value, asset: transam_asset)
      end

      depr_entry.destroy!
    end

    transam_asset.update_asset_book_value
  end

end
