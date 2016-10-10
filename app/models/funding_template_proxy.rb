class FundingTemplateProxy < Proxy

  # key for the asset being manipulated
  attr_accessor     :object_key

  attr_accessor     :funding_source_id
  attr_accessor     :name
  attr_accessor     :external_id
  attr_accessor     :description
  attr_accessor     :contributor_id
  attr_accessor     :owner_id
  attr_accessor     :transfer_only
  attr_accessor     :recurring
  attr_accessor     :match_required
  attr_accessor     :active
  attr_accessor     :all_organizations
  attr_accessor     :query_string
  attr_accessor     :organization_ids
  attr_accessor     :funding_template_type_ids


  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  # Set resonable defaults for a depreciable asset
  def set_defaults(a)
    unless a.nil?
      self.object_key = a.object_key
      self.funding_source_id = a.funding_source_id
      self.name = a.name
      self.external_id = a.external_id
      self.description = a.description
      self.contributor_id = a.contributor_id
      self.owner_id = a.owner_id
      self.transfer_only = a.transfer_only
      self.recurring = a.recurring
      self.match_required = a.match_required
      self.active = a.active
      self.query_string = a.query_string
      self.organization_ids = a.organization_ids
      self.funding_template_type_ids = a.funding_template_type_ids
      if a.query_string.blank? || a.query_string != 'id > 0'
        self.all_organizations = false
      else
        self.all_organizations = true
      end

    end
  end

  FORM_PARAMS = [
      :funding_source_id,
      :name,
      :external_id,
      :description,
      :contributor_id,
      :owner_id,
      :transfer_only,
      :recurring,
      :match_required,
      :active,
      :query_string,
      :organization_ids,
      :all_organizations,
      {:funding_template_type_ids=>[]}
  ]

end
