# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class GeneralLedgerAccountSearcher < BaseSearcher

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  # add any search params to this list.  Grouped based on their logical queries
  attr_accessor :organization_id,

                :account_number,
                :name,
                :mapping,

                :event_date,
                :event_date_comparator,
                :description,

                :asset_type_id,
                :asset_subtype_id,
                :asset_tag



  # Return the name of the form to display
  def form_view
    'general_ledger_account_search_form'
  end
  # Return the name of the results table to display
  def results_view
    'general_ledger_account_search_results_table'
  end

  def initialize(attributes = {})

    super(attributes)

    @klass = GeneralLedgerAccountEntry.joins(:general_ledger_account, :asset)
  end

  def to_s
    queries(false).to_sql
  end

  def cache_variable_name
    GeneralLedgerAccountsController::INDEX_KEY_LIST_VAR
  end

  def cache_params_variable_name
    "general_ledger_account_query_search_params_var"
  end

  def default_sort
    'general_ledger_account_entries.event_date'
  end

  private

  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------

  def asset_tag_conditions
    @klass.where(assets: {asset_tag: asset_tag}) unless asset_tag.blank?
  end

  def asset_subtype_conditions
    clean_asset_subtype_ids = remove_blanks(asset_subtype_id)
    @klass.where(assets: {asset_subtype_id: clean_asset_subtype_ids}) unless clean_asset_subtype_ids.empty?
  end

  def asset_type_conditions
    clean_asset_type_ids = remove_blanks(asset_type_id)
    @klass.where(assets: {asset_type_id: clean_asset_type_ids}) unless clean_asset_type_ids.empty?
  end

  def mapping_conditions
    gl_mapping_accts = []

    gl_mapping_accts << :asset_account_id if mapping.include? 'asset_account'
    gl_mapping_accts << :accumulated_depr_account_id if mapping.include? 'accumulated_depr_account'
    gl_mapping_accts << :depr_expense_account_id if mapping.include? 'depr_expense_account'
    gl_mapping_accts << :gain_loss_account_id if mapping.include? 'gain_loss_account'

    unless gl_mapping_accts.empty?
      gl_mappings = gl_mapping_accts.count == 1 ? GeneralLedgerMapping.pluck(*gl_mapping_accts) : GeneralLedgerMapping.pluck(*gl_mapping_accts).flatten!
      @klass.where(general_ledger_account_entries: {general_ledger_account_id: gl_mappings})
    end


  end

  def account_number_conditions
    @klass.where(general_ledger_accounts: {account_number: account_number} ) unless account_number.blank?
  end

  def name_conditions
    @klass.where('general_ledger_accounts.name LIKE ?',"%#{name}%") unless name.blank?
  end

  def event_date_conditions
    unless event_date.blank?
      case event_date_comparator
        when "-1" # Before Year X
          @klass.where("general_ledger_account_entries.event_date < ?", event_date)
        when "0" # During Year X
          @klass.where("general_ledger_account_entries.event_date = ?", event_date)
        when "1" # After Year X
          @klass.where("general_ledger_account_entries.event_date > ?", event_date)
      end
    end
  end

  def description_conditions
    @klass.where('general_ledger_account_entries.description LIKE ?',"%#{description}%") unless description.blank?
  end

  def organization_conditions
    # This method works with both individual inputs for organization_id as well
    # as arrays containing several organization ids.

    clean_organization_id = remove_blanks(organization_id)
    @klass.where(assets: {organization_id: clean_organization_id})
  end


  # Removes empty spaces from multi-select forms

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end

end
