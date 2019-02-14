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
    comments = "Amendment #{version.item.amendment_num} was #{version.event}d."

    if version.event != 'destroy' && version.changeset['comments'].present?
      comments += " #{version.changeset['comments'][1]}"
    end

    [{
        datetime: version.created_at,
        event: "Amendment #{version.event.titleize}d",
        event_type: "#{version.event.titleize}d",
        comments: comments,
        user: version.actor
    }]
  end
end
