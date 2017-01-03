class ExpenseType < ActiveRecord::Base

  belongs_to  :organization

  # Active scope -- always use this scope in forms
  scope :active, -> { where(active: true) }

  def to_s
    name
  end

end
