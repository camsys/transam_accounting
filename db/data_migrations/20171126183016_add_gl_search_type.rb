class AddGlSearchType < ActiveRecord::DataMigration
  def up
    SearchType.create(name: 'General Ledger Account', class_name: 'GeneralLedgerAccountSearcher', active: true) if SearchType.find_by(class_name: 'GeneralLedgerAccountSearcher').nil?
  end

  def down
    SearchType.find_by(class_name: 'GeneralLedgerAccountSearcher').destroy
  end
end