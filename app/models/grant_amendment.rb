class GrantAmendment < ApplicationRecord

  has_paper_trail

  include TransamObjectKey

  belongs_to :grant, touch: true

  belongs_to  :creator, -> { unscope(where: :active) },     :class_name => "User",  :foreign_key => :created_by_user_id

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


  def self.formatted_version(version)
    [{
        datetime: version.created_at,
        event: "Amendment #{version.event.titleize}d",
        event_type: "#{version.event.titleize}d",
        comments: "Amendment #{version.changeset['amendment_num'][1]} was #{version.event}d. #{version.event == 'destroy' ? '' : version.changeset['comments'][1]}",
        user: version.actor
    }]
  end
end
