module TransamValuable
  #------------------------------------------------------------------------------
  #
  # Depreciable
  #
  # Injects methods and associations for depreciating assets and tracking depreciable
  # values.
  #
  # Model
  #
  #   The following properties are injected into the Asset Model
  #
  #
  #   :depreciable     -- boolean, true if the asset is depreciable, false otherwise
  #
  #   :depreciation_start_date -- the date that the asset starts depreciating. This is
  #                         usually the same as the in_service_date but can be changed
  #                         depending on specific needs.
  #
  #   :current_depreciation_date -- the date that the book value for the asset is calculated
  #                         for. This is generally the last day of the tax year.
  #
  #   :book_value        -- the depreciated value of the asset as of the current_depreciation_date
  #
  #   :salvage_value     -- the salvage value of the asset
  #
  #------------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    #------------------------------------------------------------------------------
    # Callbacks
    #------------------------------------------------------------------------------
    before_validation  :set_depreciation_defaults
    after_save         :update_asset_book_value
    after_create       :set_depreciation_useful_life

    #----------------------------------------------------
    # Associations
    #----------------------------------------------------

    # each asset was purchased using some sources
    has_many    :grant_purchases,  :foreign_key => :transam_asset_id, :dependent => :destroy, :inverse_of => :transam_asset
    has_many    :grant_grant_purchases, -> { where(sourceable_type: 'Grant') },  :foreign_key => :transam_asset_id, :dependent => :destroy, :inverse_of => :transam_asset, class_name: 'GrantPurchase'
    has_many    :funding_source_grant_purchases, -> { where(sourceable_type: 'FundingSource') },  :foreign_key => :transam_asset_id, :dependent => :destroy, :inverse_of => :transam_asset, class_name: 'GrantPurchase'

    has_many :grants, through: :grant_purchases, :source => :sourceable, :source_type => 'Grant'
    has_many :funding_sources, through: :grant_purchases, :source => :sourceable, :source_type => 'FundingSource'

    # Allow the form to submit grant purchases
    accepts_nested_attributes_for :grant_purchases, :reject_if => :all_blank, :allow_destroy => true
    accepts_nested_attributes_for :grant_grant_purchases, :reject_if => :all_blank, :allow_destroy => true
    accepts_nested_attributes_for :funding_source_grant_purchases, :reject_if => :all_blank, :allow_destroy => true

    has_many :depreciation_entries, :foreign_key => :transam_asset_id

    has_many   :book_value_updates, -> {where :asset_event_type_id => BookValueUpdateEvent.asset_event_type.id }, :class_name => "BookValueUpdateEvent",  :as => Rails.application.config.asset_base_class_name.underscore.to_sym

    has_and_belongs_to_many    :expenditures, :join_table => :assets_expenditures, :foreign_key => :transam_asset_id

    has_many :general_ledger_account_entries, :foreign_key => :transam_asset_id

    #----------------------------------------------------
    # Validations
    #----------------------------------------------------

    validates  :depreciation_start_date,    :presence => true
    #validates  :current_depreciation_date,  :presence => true
    validates  :book_value,                 :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
    validates  :salvage_value,              :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
    validates_inclusion_of :depreciable, :in => [true, false]

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  module ClassMethods
    def self.allowable_params
      [
          :grant_purchases_attributes => [GrantPurchase.allowable_params],
          :grant_grant_purchases_attributes => [GrantPurchase.allowable_params],
          :funding_source_grant_purchases_attributes => [GrantPurchase.allowable_params]
      ]
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  def depreciation_months_left(on_date=Date.today)
    num_months_initial = self.depreciation_useful_life.nil? ? self.policy_analyzer.get_min_service_life_months : self.depreciation_useful_life
    last_depr_date = on_date - (self.policy_analyzer.get_depreciation_interval_type.months).months
    num_months_used =  last_depr_date > depreciation_start_date ? (last_depr_date.year * 12 + last_depr_date.month) - (depreciation_start_date.year * 12 + depreciation_start_date.month) : 0
    num_months_extended = self.rehabilitation_updates.sum(:extended_useful_life_months)
    num_months_unused = num_months_initial-num_months_used+num_months_extended

    num_months_unused
  end

  def original_cost_basis
    self.depreciation_purchase_cost || self.purchase_cost
  end

  def adjusted_cost_basis
    original_cost_basis + expenditures.sum(:amount) + rehabilitation_updates.sum(:total_cost)
  end

  def original_depreciation_useful_life_months
    self.depreciation_useful_life || self.expected_useful_life
  end

  def adjusted_depreciation_useful_life_months
    original_depreciation_useful_life_months + expenditures.sum(:extended_useful_life_months) + rehabilitation_updates.sum(:extended_useful_life_months)
  end

  # Render the asset as a JSON object -- overrides the default json encoding
  def depreciable_as_json(options={})
    {
      :depreciable => self.depreciable,
      :depreciation_start_date => self.depreciation_start_date,
      :book_value => self.book_value,
      :salvage_value => self.salvage_value,
      :depreciation_date => self.current_depreciation_date
    }
  end

  # returns the number of months the asset has depreciated
  def depreciation_months(on_date=Date.today, start_date=nil)
    if start_date.nil?
      start_date = depreciation_start_date
    end
    (on_date.year * 12 + on_date.month) - (start_date.year * 12 + start_date.month)
  end

  def get_depreciation_table

    gl_mapping = self.general_ledger_mapping

    table = []
    start_book_val = 0
    self.depreciation_entries.order(:event_date).each_with_index do |depr_entry, idx|
      start_book_val += depr_entry.book_value
      table << {
          :on_date => depr_entry.event_date,
          :description => depr_entry.description,
          :amount => depr_entry.book_value,
          :book_value => start_book_val
      }

      if ChartOfAccount.find_by(organization_id: self.organization_id) && gl_mapping.present?
        table[-1][:general_ledger_account] = ''
        if depr_entry.description.include? 'Purchase'
          table[-1][:general_ledger_account] = gl_mapping.asset_account
        elsif (depr_entry.description.include? 'Depreciation Expense') || (depr_entry.description.include? 'Manual Adjustment')
          table[-1][:general_ledger_account] = gl_mapping.depr_expense_account
        elsif depr_entry.description.include? 'Disposal'
          table[-1][:general_ledger_account] = gl_mapping.gain_loss_account
        elsif depr_entry.description.include? 'CapEx'
          description = depr_entry.description[7..-1]
          table[-1][:general_ledger_account] = self.expenditures.find_by(expense_date: depr_entry.event_date, description: description).try(:general_ledger_account)
        elsif depr_entry.description.include? 'Rehab'
          description = depr_entry.description[7..-1]
          table[-1][:general_ledger_account] = self.rehabilitation_updates.find_by(event_date: depr_entry.event_date, comments: description).try(:general_ledger_account)
        end
      end
    end
    return table
  end

  # updates the book value of an asset
  def update_asset_book_value
    Rails.logger.info "Updating book value for asset = #{object_key}"

    if depreciable

      gl_mapping = general_ledger_mapping

      if depreciation_entries.count == 0 # add the initial depr entry if it does not exist
        depreciation_entries.create!(description: 'Purchase', book_value: depreciation_purchase_cost, event_date: depreciation_start_date)

        if gl_mapping.present?
          gl_mapping.asset_account.general_ledger_account_entries.create!(event_date: depreciation_start_date, description: "Purchase: #{asset_path}", amount: depreciation_purchase_cost, asset: self)
        end

        depr_start = depreciation_start_date
      else
        depr_start = current_depreciation_date || depreciation_start_date
      end

      # check and set the asset book value from the depr entries
      self.update_columns(book_value: depreciation_entries.sum(:book_value))
      while depr_start <= policy_analyzer.get_current_depreciation_date
        self.update_columns(current_depreciation_date: policy_analyzer.get_depreciation_date(depr_start))

        # get this interval's system calculated depreciation
        if depreciation_entries.where(description: 'Depreciation Expense', event_date: current_depreciation_date).count == 0
          # see what algorithm we are using to calculate the book value
          class_name = policy_analyzer.get_depreciation_calculation_type.class_name
          book_val = (calculate(self, class_name) + 0.5).to_i

          depr_amount = book_val - self.book_value
          self.depreciation_entries.create!(description: 'Depreciation Expense', book_value: depr_amount, event_date: current_depreciation_date)
          self.update_columns(book_value: book_val)

          if gl_mapping.present? # check whether this app records GLAs at all
            gl_mapping.accumulated_depr_account.general_ledger_account_entries.create!(event_date: current_depreciation_date, description: "Accumulated Depreciation: #{asset_path}", amount: depr_amount, asset: self)

            gl_mapping.depr_expense_account.general_ledger_account_entries.create!(event_date: current_depreciation_date, description: "Depreciation Expense: #{asset_path}", amount: -depr_amount, asset: self)
          end
        end

        depr_start = depr_start + (policy_analyzer.get_depreciation_interval_type.months).months
      end

    else
      self.update_columns(book_value: depreciation_purchase_cost)

      #update current depreciation date
      self.update_columns(current_depreciation_date: policy_analyzer.get_current_depreciation_date)
    end
  end

  def asset_path
    url = Rails.application.routes.url_helpers.inventory_path(self)
    "<a href='#{url}'>#{self.asset_tag}</a>"
  end

  def general_ledger_mapping
    if ChartOfAccount.find_by(organization_id: self.organization_id)
      GeneralLedgerMapping.find_by(chart_of_account_id: ChartOfAccount.find_by(organization_id: self.organization_id).id, asset_subtype_id: self.asset_subtype_id)
    end
  end

  protected

    # Set resonable defaults for a new asset
    def set_depreciation_defaults
      self.depreciation_start_date ||= self.in_service_date
      self.depreciation_useful_life ||= self.expected_useful_life unless new_record?
      self.depreciation_purchase_cost ||= self.purchase_cost
      self.book_value ||= self.depreciation_purchase_cost.to_i
      self.salvage_value ||= 0
      self.depreciable = self.depreciable.nil? ? true : self.depreciable

      return true # always return true so can continue to validations

    end

    def set_depreciation_useful_life
      update_columns(depreciation_useful_life: self.expected_useful_life)
    end


    #------------------------------------------------------------------------------
    #
    # Private Methods
    #
    #------------------------------------------------------------------------------
    private

end
