class AddGrantManagerRolePrivilege < ActiveRecord::DataMigration
  def up
    Role.create!(name: 'grant_manager', weight: 11, show_in_user_mgmt: true, privilege: true)

    # update current users
    User.with_any_role(:transit_manager, :manager).each do |usr|
      usr.add_role :grant_manager
    end
  end
end