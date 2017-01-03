module Abilities
  class SuperManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      can :manage, FundingSource

    end
  end
end