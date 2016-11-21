module Abilities
  class SuperManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      can :manage, FundingSource
      can :manage, FundingTemplate
      can :manage, FundingBucket

    end
  end
end