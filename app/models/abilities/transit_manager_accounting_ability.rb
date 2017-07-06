module Abilities
  class TransitManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)
      can :manage, Grant, :organization_id => user.organization_ids
      cannot :destroy, Grant do |g|
        !g.can_destroy?
      end

      can :manage, GeneralLedgerAccount, :organization_id => user.organization_ids
      cannot :destroy, GeneralLedgerAccount do |g|
        !g.can_destroy?
      end


    end
  end
end