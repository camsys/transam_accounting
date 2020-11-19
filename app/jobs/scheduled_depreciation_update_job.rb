# --------------------------------
# # DEPRECATED see TTPLAT-1832 or https://wiki.camsys.com/pages/viewpage.action?pageId=51183790
# --------------------------------

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

    # Cache the system user
    sys_user = get_system_user

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
      matches = org.assets.where(depreciable: true).where('current_depreciation_date IS NULL OR current_depreciation_date < ?', current_depreciation_date).pluck(:object_key)

      if matches.empty?
        msg = "#{matches.count} need to be depreciated."
        Rails.logger.info msg
        ActivityLog.create({:organization => org, :user => sys_user, :item_type => self.class.name, :activity => msg, :activity_time => Time.now})
      else
        Rails.logger.info "Updating #{matches.count} assets for #{org}"

        matches.each do |key|
          # Create a delayed job to perform the update
          job = AssetValueUpdateJob.new(key)
          Delayed::Job.enqueue job, :priority => JOB_PRIORITY
        end

        # Insert a row in the activity log for this org
        msg = "#{matches.count} assets were depreciated."
        ActivityLog.create({:organization => org, :user => sys_user, :item_type => self.class.name, :activity => msg, :activity_time => Time.now})

        # Send a message to the managers of the organization
        message_subject = "Depreciated values of assets updated"
        message_body = "#{matches.count} depreciable assets have had their book value updated. The new current depreciation date is #{current_depreciation_date}."
        org.users.each do |user|
          if user.has_role? :manager
            message = Message.new
            message.organization = org
            message.to_user = user
            message.user = sys_user
            message.subject = message_subject
            message.body = message_body
            message.save
          end
        end
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
