module Abilities
  class TransitManagerAccountingAbility
    include CanCan::Ability

    def initialize(user)

      can :new_bucket_app, FundingBucket
      can [:read, :edit_bucket_app, :destroy_bucket_app], FundingBucket do |b|
        user.organization_ids.include? b.owner_id
      end
      
    end
  end
end