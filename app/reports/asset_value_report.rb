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
      typed_asset = Asset.get_typed_asset(asset)
      data[idx].insert(-2, typed_asset.adjusted_cost_basis, typed_asset.adjusted_cost_basis-asset.book_value)
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

    params[:calendar_month] = Date.today.month unless params[:calendar_month].to_i > 0
    params[:calendar_year] = Date.today.year if params[:calendar_year].blank?

    params[:group_by] = ['by_agency', 'by_type', 'by_subtype'] if params[:group_by].nil?

    end_date = Date.new(params[:calendar_year].to_i, params[:calendar_month].to_i, 1).end_of_month

    book_value_query = Asset.operational
                           .joins(:organization, :asset_type, :asset_subtype)
                           .joins('INNER JOIN depreciation_entries ON assets.id = depreciation_entries.asset_id')
                           .joins('INNER JOIN general_ledger_account_entries ON general_ledger_account_entries.asset_id = assets.id')
                           .joins('INNER JOIN general_ledger_accounts ON general_ledger_accounts.id = general_ledger_account_entries.general_ledger_account_id')
                           .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.asset_account_id = general_ledger_accounts.id')
                           .where(organization_id: organization_id_list).where('depreciation_entries.event_date <= ?', end_date)

    fixed_asset = GeneralLedgerAccountEntry.unscoped
                      .joins(:general_ledger_account, :asset)
                      .joins('INNER JOIN general_ledger_mappings ON general_ledger_mappings.asset_account_id = general_ledger_accounts.id')
                      .joins('INNER JOIN asset_subtypes ON assets.asset_subtype_id = asset_subtypes.id')
                      .joins('INNER JOIN asset_types ON asset_subtypes.asset_type_id = asset_types.id')
                      .joins('INNER JOIN chart_of_accounts ON general_ledger_mappings.chart_of_account_id = chart_of_accounts.id')
                      .joins('INNER JOIN organizations ON chart_of_accounts.organization_id = organizations.id')
                      .where('organizations.id IN (?) AND amount > 0 AND event_date <= ?', organization_id_list, end_date)


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
          book_value_query = book_value_query.group(clause).order(clause)
          fixed_asset = fixed_asset.group(clause).order(clause)

          labels << 'Asset Acct'
          formats << :string
          clause = 'general_ledger_accounts.account_number'
      end
      @clauses << clause
      book_value_query = book_value_query.group(clause).order(clause)
      fixed_asset = fixed_asset.group(clause).order(clause)

    end

    asset_count = book_value_query.count('DISTINCT(assets.id)')
    book_value_query = book_value_query.sum('depreciation_entries.book_value')
    fixed_asset = fixed_asset.sum('general_ledger_account_entries.amount')

    data = []
    if params[:group_by]
      # Add initial book value
      book_value_query.each do |k, v|
        data << [*k]
        data[-1] << asset_count[k].to_i
        data[-1] << fixed_asset[k].to_i
        data[-1] << fixed_asset[k].to_i - v.to_i
        data[-1] << v.to_i
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