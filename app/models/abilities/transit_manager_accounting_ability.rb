module Abilities
  class TransitManagerAccountingAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      can :manage, Grant, :organization_id => organization_ids

      can :manage, GeneralLedgerAccount do |gla|
        organization_ids.include? gla.chart_of_account.organization_id
      end


    end
  end
end