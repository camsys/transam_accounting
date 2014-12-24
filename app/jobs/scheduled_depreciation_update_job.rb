#------------------------------------------------------------------------------
#
# ScheduledDepreciationUpdateJob
#
# Schedule:   1st day of each month
# Scope:      All organizations, all assets
# Priority:   < 10
#
# This job takes each organization and checks to see if the assets need to have
# their book_value (depreciated value) updated based on the frequency determined
# in the policy
#
#------------------------------------------------------------------------------
class ScheduledDepreciationUpdateJob < Job

  # The priority to run jobs that are created by this job. This priority
  # should always be higher than the current job priority to avoid race
  # conditiopns
  JOB_PRIORITY = 10

  def run

    # Check each org and determine if they need to have their assets
    # depreciated
    Organization.all.each do |o|
      # Make sure the org is fully typed so any class-specific behaviors
      # are managed
      org = Organization.get_typed_organization(o)

      # Make sure they have assets
      unless org.has_assets?
        next
      end

      # Get the policy for the org and check to see what the current_depreciation_date is
      current_depreciation_date = org.get_policy.current_depreciation_date

      # Find the depreciable assets for this organization where the current depreciation date for the assets is
      # before the current depeciation date. We only need the object keys
      matches = org.assets.where('depreciable = true AND current_depreciation_date < ?', current_depreciation_date).pluck(:object_key)

      Rails.logger.info "Updating #{matches.count} assets for #{org}"

      matches.each do |key|
        # Create a delayed job to perform the update
        job = AssetValueUpdateJob.new(key)
        Delayed::Job.enqueue job, :priority => JOB_PRIORITY
      end


    end
    Rails.logger.info "#{self.class.name} finished at #{Time.now}"

  end

  def prepare
    Rails.logger.info "Executing #{self.class.name} at #{Time.now}"
  end

  def check
    true
  end

  def initialize
    super
  end

end
