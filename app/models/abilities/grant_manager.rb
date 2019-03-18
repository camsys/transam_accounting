module Abilities
  class GrantManager
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      can :manage, Grant do |grant|
        user.viewable_organization_ids.include? grant.owner_id
      end

    end

  end
end