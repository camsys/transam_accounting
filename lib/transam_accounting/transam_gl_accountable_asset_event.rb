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
    assets.each do |asset|
      gl_mapping = GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: asset.organization_id).id, asset_subtype_id: asset.asset_subtype_id)
      if gl_mapping.present? # check whether this app records GLAs at all

        gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: expense_date, description: "Rehab #{asset.asset_path}", amount: self.total_cost)

        self.general_ledger_account.general_ledger_account_entries.create!(event_date: expense_date, description: "Rehab #{asset.asset_path}", amount: -self.total_cost)
      end

      asset.depreciation_entries.create!(description: "CapEx #{self.description}", book_value: asset.book_value + self.total_cost, event_date: expense_date)
      asset.update(book_value: asset.book_value + self.total_cost)
    end
  end

end
