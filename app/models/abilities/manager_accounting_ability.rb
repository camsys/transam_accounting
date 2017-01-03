module Abilities
  class ManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      # create new expense categories
      can :create, ExpenseType

    end
  end
end