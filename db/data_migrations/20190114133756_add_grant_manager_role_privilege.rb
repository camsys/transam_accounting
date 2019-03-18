class AddGrantManagerRolePrivilege < ActiveRecord::DataMigration
  def up
    Role.create!(name: 'grant_manager', weight: 11, show_in_user_mgmt: true, privilege: true)
  end
end