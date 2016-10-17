class FundingBucketProxy < Proxy

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------

  # has_many :bucket_agency_allocation

  # key for the asset being manipulated
  attr_accessor   :object_key
  attr_accessor   :option
  attr_accessor   :program_id
  attr_accessor   :template_id
  attr_accessor   :owner_id
  attr_accessor   :fiscal_year_range_start
  attr_accessor   :fiscal_year_range_end
  attr_accessor   :total_amount
  # attr_accessor   :bucket_type_id
  attr_accessor   :inflation_percentage
  attr_accessor   :description
  attr_accessor   :bucket_agency_allocations



  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
      :object_key,
      :option,
      :program_id,
      :template_id,
      :owner_id,
      :fiscal_year_range_start,
      :fiscal_year_range_end,
      :total_amount,
      # :bucket_type_id,
      :inflation_percentage,
      :description,
      :bucket_agency_allocations
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  # Set resonable defaults for a depreciable asset
  def set_defaults
    self.bucket_agency_allocations = []
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  def initialize(attrs = {})
    super
    self.bucket_agency_allocations = []
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

end