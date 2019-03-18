module Abilities
  class AuthorizedAccountingAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      cannot :read, Grant


    end
  end
end