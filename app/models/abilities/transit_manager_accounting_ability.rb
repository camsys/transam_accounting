module Abilities
  class TransitManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)
      can [:create, :update], Grant, :organization_id => user.organization_ids

      can [:create, :update], GeneralLedgerAccount, :organization_id => user.organization_ids


    end
  end
end