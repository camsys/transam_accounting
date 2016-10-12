class BucketType < ActiveRecord::Base

  has_and_belongs_to_many  :buckets

  # Active scope -- always use this scope in forms
  scope :active, -> { where(active: true) }

  def to_s
    name
  end

end