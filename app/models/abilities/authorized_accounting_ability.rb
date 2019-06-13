module Abilities
  class AuthorizedAccountingAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end


      cannot :read, Grant

      can :create, Comment do |c|
        if c.commentable_type == 'Asset'
          user.organization_ids.include? c.commentable.organization.id
        elsif c.commentable_type == 'FundingSource'
          false
        else
          true
        end
      end

      can :create, Document do |d|
        if d.documentable_type == 'Asset'
          user.organization_ids.include? d.documentable.organization.id
        elsif d.documentable_type == 'FundingSource'
          false
        else
          true
        end
      end


    end
  end
end