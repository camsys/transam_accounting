module Abilities
  class ManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      # create new expense categories
      can :create, ExpenseType

      # if no super manager, manager manages funding programs
      if Role.find_by(name: 'super_manager').nil?
        can :manage, FundingSource
      end

    end
  end
end