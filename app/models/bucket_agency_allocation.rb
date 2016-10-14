class BucketAgencyAllocation

  attr_accessor   :agency_id
  attr_accessor   :agency_name
  attr_accessor   :amount

  def set_defaults_from_organization(org)
    self.agency_id = org.id
    self.agency_name = org.short_name
    self.amount = nil
  end
end