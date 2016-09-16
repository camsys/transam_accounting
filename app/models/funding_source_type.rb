#------------------------------------------------------------------------------
#
# FundingSourceType
#
# Lookup Table for types of funding sources. Initially: state/federal/local.
#
#------------------------------------------------------------------------------
class FundingSourceType < ActiveRecord::Base

  # Has many funding sources
  has_many    :funding_sources

  # All types that are available
  scope :active, -> { where(:active => true) }
  scope :funding_program, -> { where("name != 'Agency'") }
  scope :contributer, -> { where("name NOT IN ('Local', 'Agency')") }
  scope :owner, -> { where("name IN ('State', 'Agency')") }
 
  def to_s
    name
  end

end
