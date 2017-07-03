class GeneralLedgerAccountSubtype < ActiveRecord::Base

  belongs_to :general_ledger_account_type

  # Active scope -- always use this scope in forms
  scope :active, -> { where(active: true) }

  def to_s
    name
  end

end
