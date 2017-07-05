#------------------------------------------------------------------------------
#
# Expenditure
#
# Represents an expenditure in TransAM. Expenditures are tracked against
# assets, general ledger accounts, and optionally grants.
#
# An expenditure can optionally be associated more than one asset, for example,
# an inspector could inspect several busses and provide a single invoice.
#
#------------------------------------------------------------------------------
class Expenditure < Asset

  # Callbacks
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations common to all expenditures
  #------------------------------------------------------------------------------

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  # set the default scope
  default_scope { where(:asset_type_id => AssetType.where(:class_name => self.name).pluck(:id)) }

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    [
    ]
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
        {
        })
  end

  # Creates a duplicate that has all asset-specific attributes nilled
  def copy(cleanse = true)
    a = dup
    a.cleanse if cleanse
    a
  end

  def searchable_fields
    a = []
    a << super
    a += [
        :description,
        :serial_number
    ]
    a.flatten
  end

  def cleansable_fields
    a = []
    a << super
    a += [
    ]
    a.flatten
  end

  # The cost of a equipment asset is the purchase cost
  def cost
    purchase_cost
  end


  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a suppoert facility
  def set_defaults
    super

    # expenditures are not depreciable and not planned for replacement
    self.depreciable = self.depreciable.nil? ? false : self.depreciable
    self.replacement_status_type_id ||= ReplacementStatusType.find_by(name: 'None').id
  end

end

