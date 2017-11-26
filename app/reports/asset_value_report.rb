class AssetValueReport < AbstractReport

  COMMON_LABELS = ['Quantity', 'Adjusted Cost Basis', 'Accumulated Depr.', 'Book Value']
  COMMON_FORMATS = [:integer, :currency, :currency, :currency]
  DETAIL_LABELS = ['Agency', 'Type', 'Subtype', 'Asset Tag', 'Adjusted Cost Basis', 'Accumulated Depr', 'Book Value']
  DETAIL_FORMATS = [:string, :string, :string, :string, :currency, :currency, :currency]

  def self.get_detail_data(organization_id_list, params)
    query = Asset.operational.joins(:organization, :asset_type, :asset_subtype).where(organization_id: organization_id_list)

    key = params[:key].split('-')
    
    (params[:group_by] || []).each_with_index do |group, i|
      case group.to_sym
      when :by_agency
        clause = 'organizations.short_name = ?'
        when :by_type
        clause = 'asset_types.name = ?'
        when :by_subtype
        clause = 'asset_subtypes.name = ?'
      end
      query = query.where(clause, key[i])
    end

    data = query.pluck(*['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'assets.asset_tag', 'assets.book_value']).to_a

    query.each_with_index do |asset, idx|
      data[idx].insert(-2, asset.adjusted_cost_basis, asset.adjusted_cost_basis-asset.book_value)
    end

    {labels: DETAIL_LABELS, data: data, formats: DETAIL_FORMATS}
  end
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_actions
    @actions = [
                {
                    type: :select,
                    where: :calendar_month,
                    values: Date::MONTHNAMES.each_with_index.collect{|m, i| [m, i]},
                    label: 'Month'
                },
                {
                    type: :select,
                    where: :calendar_year,
                    values: (Date.today.year-SystemConfig.instance.num_forecasting_years..Date.today.year).to_a,
                    label: 'Year'
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
    
    # Default scope orders by project_id
    query = Asset.operational.joins(:organization, :asset_type, :asset_subtype).where(organization_id: organization_id_list)
    query = query.joins("#{GeneralLedgerAccount.unscoped.select('general_ledger_mappings.asset_subtype_id', 'account_number').joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.asset_account_id = general_ledger_accounts.id').joins(chart_of_account: :organization).where(organizations: {id: 3}).to_sql}")
    rehabs = RehabilitationUpdateEvent.unscoped.joins(asset: [:organization, :asset_type, :asset_subtype]).where(assets: {organization_id: organization_id_list})
    expenditures = Expenditure.joins(assets: [:organization, :asset_type, :asset_subtype]).where(assets: {organization_id: organization_id_list})

    params[:calendar_month] = Date.today.month unless params[:calendar_month].to_i > 0
    params[:calendar_year] = Date.today.year if params[:calendar_year].blank?

    params[:group_by] = ['by_agency', 'by_type', 'by_subtype'] if params[:group_by].nil?

    end_date = Date.new(params[:calendar_year].to_i, params[:calendar_month].to_i, 1).end_of_month

    book_value_query = Asset.operational.joins(:organization, :asset_type, :asset_subtype).joins('INNER JOIN depreciation_entries ON assets.id = depreciation_entries.asset_id').where(organization_id: organization_id_list).where('event_date <= ?', end_date)

    fixed_asset = GeneralLedgerAccountEntry
                      .joins(:general_ledger_account, :asset)
                      .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.asset_account_id = general_ledger_accounts.id')
                      .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                      .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                      .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                      .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                      .where('organizations.id IN (?) AND amount > 0 AND event_date <= ?', organization_id_list, end_date)
    accumulated_depr = GeneralLedgerAccountEntry
                           .joins(:general_ledger_account, :asset)
                           .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.accumulated_depr_account_id = general_ledger_accounts.id')
                           .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                           .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                           .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                           .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                           .where('organizations.id IN (?) AND event_date <= ?', organization_id_list, end_date)


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
          @clauses << clause

          labels << 'Asset Acct'
          formats << :string
          clause = 'general_ledger_accounts.account_number'
      end
      @clauses << clause
      book_value_query = book_value_query.group(clause).order(clause)
      fixed_asset = fixed_asset.group(clause).order(clause)
      accumulated_depr = accumulated_depr.group(clause).order(clause)

    end

    book_value_query = book_value_query.sum('depreciation_entries.book_value')
    fixed_asset = fixed_asset.sum('general_ledger_account_entries.amount')
    accumulated_depr = accumulated_depr.sum('general_ledger_account_entries.amount')

    data = []
    if params[:group_by]
      # Add initial book value
      book_value_query.each do |k, v|
        data << [*k]
        data[-1] << fixed_asset[k] || 0
        data[-1] << accumulated_depr[k] || 0
        data[-1] << v
      end
    end

    return {labels: labels + COMMON_LABELS, data: data, formats: formats + COMMON_FORMATS}
  end

  def get_key(row)
    row.slice(0, @clauses.count).join('-')
  end

  def get_detail_path(id, key, opts={})
    ext = opts[:format] ? ".#{opts[:format]}" : ''
    "#{id}/details#{ext}?key=#{key}&#{@group_by.to_query}"
  end

  def get_detail_view
    "generic_report_detail"
  end

end