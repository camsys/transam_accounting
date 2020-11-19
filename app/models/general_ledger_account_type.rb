# --------------------------------
# # NOT USED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------


class GeneralLedgerAccountType < ActiveRecord::Base

  # Active scope -- always use this scope in forms
  scope :active, -> { where(active: true) }

  def to_s
    name
  end

end
