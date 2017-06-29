module Abilities
  class TransitManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)
      can :manage, Grant, :organization_id => user.organization_ids

      can :manage, GeneralLedgerAccount, :organization_id => user.organization_ids

    end
  end
end