module Abilities
  class AuthorizedAccountingAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Expenditures
      #-------------------------------------------------------------------------
      # User can manage expenditures if the expense is owned by their organization
      can :manage, Expenditure do |e|
        e.organization_id == user.organization_id
      end

    end
  end
end