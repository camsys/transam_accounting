class DepreciationIntervalType < ActiveRecord::Base

  # Active scope -- always use this scope in forms
  scope :active, -> { where(active: true) }

end
