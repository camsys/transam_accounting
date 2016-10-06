class BucketProxy < Proxy
  # key for the asset being manipulated
  attr_accessor     :object_key

  attr_accessor   :program_id
  attr_accessor   :template_id
  attr_accessor   :owner_id
  attr_accessor   :fiscal_year_range_start
  attr_accessor   :fiscal_year_range_end
  attr_accessor   :total_amount
  attr_accessor   :bucket_type_id
  attr_accessor   :inflation_percentage
  attr_accessor   :description
  attr_accessor   :bucket_agency_allocations




    # Set resonable defaults for a depreciable asset
    def set_defaults(a)
      unless a.nil?

      end
    end

end