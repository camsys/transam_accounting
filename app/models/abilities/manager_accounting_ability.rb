module Abilities
  class ManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      # if no super manager, manager manages funding programs
      if Role.find_by(name: 'super_manager').nil?
        can :manage, FundingSource
      end

      # BPT user can add comments on any asset
      can :create, Comment do |c|
        if c.commentable_type == 'FundingSource'
          false
        else
          true
        end
      end

    end
  end
end