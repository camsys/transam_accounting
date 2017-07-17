module Abilities
  class TransitManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)
      can [:create, :update], Grant, :organization_id => user.organization_ids

      can [:create, :update], GeneralLedgerAccount do |gla|
        user.organization_ids.include? gla.chart_of_account.organization_id
      end


    end
  end
end