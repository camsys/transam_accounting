class ExpenseType < ActiveRecord::Base

  belongs_to  :organization
            
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end

end

