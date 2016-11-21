module Abilities
  class AuthorizedAccountingAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Funding
      #-------------------------------------------------------------------------

      cannot :read, FundingTemplate
      cannot :read, FundingBucket do |b|
        !(user.organization_ids.include? b.owner_id)
      end
      can :my_funds, FundingBucket

      #-------------------------------------------------------------------------
      # Expenditures
      #-------------------------------------------------------------------------
      # User can manage expenditures if the expense is owned by their organization
      can :manage, Expenditure do |e|
        e.organization_id == user.organization_id
      end

      can :manage, Grant, :organization_id => user.organization_ids

      can :manage, GeneralLedgerAccount, :organization_id => user.organization_ids

    end
  end
end