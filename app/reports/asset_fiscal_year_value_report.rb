class AssetFiscalYearValueReport < AbstractReport

  include FiscalYear

  COMMON_LABELS = ['Value FY Start', 'Fixed Asset', 'Depr. Expense', 'Accumulated Depr.', 'Gain/Loss', 'Value FY End']
  COMMON_FORMATS = [:currency, :currency, :currency, :currency, :currency, :currency]
  DETAIL_LABELS = ['Asset Tag']
  DETAIL_FORMATS = [:string]

  def self.get_detail_data(organization_id_list, params)
    key = params[:key].split('-')

    params[:fy_year] = key[0]

    # Default scope orders by project_id
    fy_start = self.new.start_of_fiscal_year(params[:fy_year].to_i)
    fy_end = self.new.start_of_fiscal_year(params[:fy_year].to_i+1)-1.day
    book_value_query = Asset.operational.joins(:organization, :asset_type, :asset_subtype).joins('INNER JOIN depreciation_entries ON assets.id = depreciation_entries.asset_id').where(organization_id: organization_id_list)

    book_value_start = book_value_query.where('event_date <= ?', fy_start)
    book_value_end = book_value_query.where('event_date <= ?', fy_end)

    fixed_asset = GeneralLedgerAccountEntry
                      .joins(:general_ledger_account, :asset)
                      .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.asset_account_id = general_ledger_accounts.id')
                      .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                      .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                      .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                      .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                      .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)
    accumulated_depr = GeneralLedgerAccountEntry
                           .joins(:general_ledger_account, :asset)
                           .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.accumulated_depr_account_id = general_ledger_accounts.id')
                           .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                           .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                           .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                           .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                           .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)
    depr_expense = GeneralLedgerAccountEntry
                       .joins(:general_ledger_account, :asset)
                       .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.depr_expense_account_id = general_ledger_accounts.id')
                       .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                       .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                       .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                       .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                       .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)
    gain_loss = GeneralLedgerAccountEntry
                    .joins(:general_ledger_account, :asset)
                    .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.gain_loss_account_id = general_ledger_accounts.id')
                    .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                    .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                    .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                    .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                    .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)

    (params[:group_by] || []).each_with_index do |group, i|
      case group.to_sym
        when :by_agency
          clause = 'organizations.short_name = ?'
        when :by_type
          clause = 'asset_types.name = ?'
        when :by_subtype
          clause = 'asset_subtypes.name = ?'
      end

      book_value_start = book_value_start.where(clause, key[i+1])
      book_value_end = book_value_end.where(clause, key[i+1])
      fixed_asset = fixed_asset.where(clause, key[i+1])
      accumulated_depr = accumulated_depr.where(clause, key[i+1])
      depr_expense = depr_expense.where(clause, key[i+1])
      gain_loss = gain_loss.where(clause, key[i+1])

    end

    book_value_start = book_value_start.group('assets.asset_tag').order('assets.asset_tag').sum('depreciation_entries.book_value')
    book_value_end = book_value_end.group('assets.asset_tag').order('assets.asset_tag').sum('depreciation_entries.book_value')
    fixed_asset = fixed_asset.group('assets.asset_tag').order('assets.asset_tag').sum('general_ledger_account_entries.amount')
    accumulated_depr = accumulated_depr.group('assets.asset_tag').order('assets.asset_tag').sum('general_ledger_account_entries.amount')
    depr_expense = depr_expense.group('assets.asset_tag').order('assets.asset_tag').sum('general_ledger_account_entries.amount')
    gain_loss = gain_loss.group('assets.asset_tag').order('assets.asset_tag').sum('general_ledger_account_entries.amount')

    data = []
    if params[:group_by]
      # Add initial book value
      book_value_end.each do |k, v|
        data << [*k]
        data[-1] << book_value_start[k] || 0
        data[-1] << fixed_asset[k] || 0
        data[-1] << depr_expense[k] || 0
        data[-1] << accumulated_depr[k] || 0
        data[-1] << gain_loss[k] || 0
        data[-1] << book_value_end[k] || 0
      end
    end

    return {labels: DETAIL_LABELS + COMMON_LABELS, data: data, formats: DETAIL_FORMATS + COMMON_FORMATS}
  end
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_actions
    @actions = [
        {
            type: :select,
            where: :fy_year,
            values: get_fiscal_years,
            label: 'FY'
        },
        {
            type: :check_box_collection,
            group: :group_by,
            values: [:by_agency, :by_type, :by_subtype]
        }
    ]
  end
  
  def get_data(organization_id_list, params)

    labels = []
    formats = []

    params[:fy_year] = current_fiscal_year_year if params[:fy_year].nil?
    @fy = params[:fy_year].to_i
    params[:group_by] = ['by_agency'] if params[:group_by].nil?

    # Default scope orders by project_id
    fy_start = start_of_fiscal_year(params[:fy_year].to_i)
    fy_end = start_of_fiscal_year(params[:fy_year].to_i+1)-1.day
    book_value_query = Asset.operational.joins(:organization, :asset_type, :asset_subtype).joins('INNER JOIN depreciation_entries ON assets.id = depreciation_entries.asset_id').where(organization_id: organization_id_list)

    book_value_start = book_value_query.where('event_date <= ?', fy_start)
    book_value_end = book_value_query.where('event_date <= ?', fy_end)

    fixed_asset = GeneralLedgerAccountEntry
                      .joins(:general_ledger_account, :asset)
                      .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.asset_account_id = general_ledger_accounts.id')
                      .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                      .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                      .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                      .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                      .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)
    accumulated_depr = GeneralLedgerAccountEntry
                           .joins(:general_ledger_account, :asset)
                           .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.accumulated_depr_account_id = general_ledger_accounts.id')
                           .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                           .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                           .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                           .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                           .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)
    depr_expense = GeneralLedgerAccountEntry
                       .joins(:general_ledger_account, :asset)
                       .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.depr_expense_account_id = general_ledger_accounts.id')
                       .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                       .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                       .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                       .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                       .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)
    gain_loss = GeneralLedgerAccountEntry
                    .joins(:general_ledger_account, :asset)
                    .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.gain_loss_account_id = general_ledger_accounts.id')
                    .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                    .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                    .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                    .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                    .where('organizations.id IN (?) AND event_date >= ? AND event_date <= ?', organization_id_list, fy_start, fy_end)


    # Add clauses based on params
    @clauses = []
    @group_by = params[:group_by] ? {group_by: params[:group_by]} : {}
    (params[:group_by] || []).each do |group|
      labels << group.to_s.titleize.split[1]
      case group.to_sym
      when :by_agency
        formats << :string
        clause = 'organizations.short_name'
      when :by_type
        formats << :string
        clause = 'asset_types.name'
      when :by_subtype
        formats << :string
        clause = 'asset_subtypes.name'
      end
      @clauses << clause
      book_value_start = book_value_start.group(clause).order(clause)
      book_value_end = book_value_end.group(clause).order(clause)
      fixed_asset = fixed_asset.group(clause).order(clause)
      accumulated_depr = accumulated_depr.group(clause).order(clause)
      depr_expense = depr_expense.group(clause).order(clause)
      gain_loss = gain_loss.group(clause).order(clause)

    end

    book_value_start = book_value_start.sum('depreciation_entries.book_value')
    book_value_end = book_value_end.sum('depreciation_entries.book_value')
    fixed_asset = fixed_asset.sum('general_ledger_account_entries.amount')
    accumulated_depr = accumulated_depr.sum('general_ledger_account_entries.amount')
    depr_expense = depr_expense.sum('general_ledger_account_entries.amount')
    gain_loss = gain_loss.sum('general_ledger_account_entries.amount')
    
    data = []
    if params[:group_by]
      # Add initial book value
      book_value_end.each do |k, v|
        data << [*k]
        data[-1] << book_value_start[k] || 0
        data[-1] << fixed_asset[k] || 0
        data[-1] << depr_expense[k] || 0
        data[-1] << accumulated_depr[k] || 0
        data[-1] << gain_loss[k] || 0
        data[-1] << book_value_end[k] || 0
      end
    end

    return {labels: labels + COMMON_LABELS, data: data, formats: formats + COMMON_FORMATS}
  end

  def get_key(row)
    "#{@fy}-" + (row.slice(0, @clauses.count)).join('-')
  end

  def get_detail_path(id, key, opts={})
    ext = opts[:format] ? ".#{opts[:format]}" : ''
    "#{id}/details#{ext}?key=#{key}&#{@group_by.to_query}"
  end

  def get_detail_view
    "generic_report_detail"
  end

end