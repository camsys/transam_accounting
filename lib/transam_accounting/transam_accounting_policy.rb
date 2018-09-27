module TransamAccountingPolicy
  #------------------------------------------------------------------------------
  #
  # Accountable
  #
  # Injects methods and associations for depreciating assets into an
  # Policy class
  #
  # Model
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    #------------------------------------------------------------------------------
    # Callbacks
    #------------------------------------------------------------------------------
    after_initialize  :set_depreciation_defaults

    after_save        :apply_depreciation_policy_changes

    # ----------------------------------------------------
    # Associations
    # ----------------------------------------------------

    # Has a single method for calculating asset depreciation
    belongs_to  :depreciation_calculation_type

    # Has a time interval for how often depreciation is calculated
    belongs_to  :depreciation_interval_type

    # ----------------------------------------------------
    # Validations
    # ----------------------------------------------------
    validates :depreciation_calculation_type,  :presence => true
    validates :depreciation_interval_type,     :presence => true



  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  module ClassMethods
    def self.allowable_params
      # List of hash parameters allowed by the controller
      [
          :depreciation_calculation_type_id,
          :depreciation_interval_type_id
      ]
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Calculates the depreciation date based on the policy and the date that has been specified.
  # This method calulates the next depreciation date
  def depreciation_date(on_date)

    return nil if on_date.nil?

    if depreciation_interval_type.id == 3
      # monthly
      d = on_date.end_of_month
    elsif depreciation_interval_type.id == 2
      # quarterly
      d = on_date.end_of_quarter
    else
      # default to end of the fiscal year
      d = fiscal_year_end_date(on_date)
    end
    d
  end

  # Based on today's date, this method returns the current depreciation date.
  # this is the last date that depreciation should be calculated for based on
  # the setting in this policy
  def current_depreciation_date
    if depreciation_interval_type.id == 3
      # monthly
      d = (Date.today - 1.month).end_of_month
    elsif depreciation_interval_type.id == 2
      # quarterly
      d = (Date.today - 3.month).end_of_quarter
    else
      # default to end of the fiscal year
      d = fiscal_year_end_date(Date.today - 1.year)
    end
    d
  end

  # Returns the next depreciation date for the org based on the policy they
  # have selected
  def next_depreciation_date
    (current_depreciation_date + depreciation_interval_type.months.months).end_of_month
  end

  protected
    # Set resonable defaults for the policy
    def set_depreciation_defaults
      if new_record?
        self.depreciation_calculation_type ||= DepreciationCalculationType.find_by_name('Straight Line')
        self.depreciation_interval_type ||= DepreciationIntervalType.find_by_name('Annually')
      end
    end

    def apply_depreciation_policy_changes
      if previous_changes.keys.any? {|x| x.include? 'depreciation' }
        Rails.application.config.asset_base_class_name.constantize.operational.where(organization_id: self.organization_id).each do |asset|
          begin
            typed_asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(asset)
            typed_asset.send(:update_asset_book_value)
          rescue Exception => e
            Rails.logger.warn e.message
          end
        end
      end
    end
    handle_asynchronously :apply_depreciation_policy_changes

end
