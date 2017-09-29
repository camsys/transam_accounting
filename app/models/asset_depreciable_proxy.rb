class AssetDepreciableProxy < Proxy

  # key for the asset being manipulated
  attr_accessor     :object_key

  attr_accessor     :depreciable
  attr_accessor     :depreciation_start_date
  attr_accessor     :depreciation_useful_life
  attr_accessor     :depreciation_purchase_cost
  attr_accessor     :salvage_value

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  # Set resonable defaults for a depreciable asset
  def set_defaults(a)
    unless a.nil?
      asset = Asset.get_typed_asset(a)
      self.object_key = asset.object_key
      self.depreciable = asset.depreciable
      self.depreciation_start_date = asset.depreciation_start_date
      self.depreciation_useful_life = asset.depreciation_useful_life
      self.depreciation_purchase_cost = asset.depreciation_purchase_cost
      self.salvage_value = asset.salvage_value

    end
  end

end
