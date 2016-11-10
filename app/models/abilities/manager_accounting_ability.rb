module Abilities
  class ManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      # create new expense categories
      can :create, ExpenseType

      #-------------------------------------------------------------------------
      # Funding
      #-------------------------------------------------------------------------

      can :read, FundingTemplate
      can [:read, :my_funds], FundingBucket
    end
  end
end