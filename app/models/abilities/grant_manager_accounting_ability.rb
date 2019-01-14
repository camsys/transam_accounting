module Abilities
  class GrantManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      can :manage, Grant

    end
  end
end