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

    FORM_PARAMS = [
        :general_ledger_account_id
    ]


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

  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------


  protected

  def create_depreciation_entry
    changed_amount = (self.total_cost - self.total_cost_was.to_i)

    gl_mapping = GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: asset.organization_id).id, asset_subtype_id: asset.asset_subtype_id)
    if gl_mapping.present? # check whether this app records GLAs at all

      gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: event_date, description: "Rehab #{asset.asset_path}", amount: changed_amount, asset: asset)

      if self.general_ledger_account.present?
        self.general_ledger_account.general_ledger_account_entries.create!(event_date: event_date, description: "Rehab #{asset.asset_path}", amount: -changed_amount, asset: asset)
      end
    end

    asset.depreciation_entries.create!(description: "Rehab #{self.comments}", book_value: changed_amount, event_date: self.event_date)

    asset.depreciation_entries.depreciation_expenses.where('event_date > ?',self.event_date).each do |depr_entry|
      if gl_mapping.present?
        gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Accumulated Depreciation #{asset.asset_path}", amount: -depr_entry.book_value, asset: asset)

        gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: event_date, description: "REVERSED Deprectiation Expense #{asset.asset_path}", amount: depr_entry.book_value, asset: asset)
      end

      depr_entry.destroy!
    end
  end

end
