module Abilities
  class SuperManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      can [:create, :update], FundingSource
      can [:create, :update], FundingTemplate
      can :manage, FundingBucket

    end
  end
end