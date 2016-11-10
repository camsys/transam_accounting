module Abilities
  class GuestAccountingAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Funding
      #-------------------------------------------------------------------------

      cannot :read, FundingTemplate
      cannot :read, FundingBucket
    end
  end
end