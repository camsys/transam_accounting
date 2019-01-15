class GrantAmendment < ApplicationRecord

  include TransamObjectKey

  belongs_to :grant

  belongs_to  :creator,     :class_name => "User",  :foreign_key => :created_by_user_id

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
      :amendment_num,
      :grant_num,
      :comments
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

end
