class DeleteOldGrants < ActiveRecord::DataMigration
  def up
    Grant.destroy_all
  end
end