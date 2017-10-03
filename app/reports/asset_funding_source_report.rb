class AssetFundingSourceReport < AbstractReport

  COMMON_LABELS = ['# Assets', 'Spent']
  COMMON_FORMATS = [:integer, :currency]
  DETAIL_LABELS = ['Asset Tag', 'Asset Type', 'Asset Subtype', 'Spent']
  DETAIL_FORMATS = [:string, :string, :string, :currency]

  def self.get_detail_data(organization_id_list, params)
    query = Asset.unscoped.joins(:organization, :asset_type, :asset_subtype)
                .joins('INNER JOIN grant_purchases ON grant_purchases.asset_id = assets.id')
                .joins('INNER JOIN funding_sources ON grant_purchases.sourceable_id = funding_sources.id')
                .where(assets: {organization_id: organization_id_list})

    key = params[:key].split('-')

    params[:group_by] = 'Funding Program, Agency' if params[:group_by].nil?
    params[:group_by].split(',').each_with_index do |grp_clause, i|
      if grp_clause.include? 'Agency'
        clause = 'organizations.short_name = ?'
      elsif grp_clause.include? 'Funding Program'
        clause = 'funding_sources.name = ?'
      elsif grp_clause.include? 'year'
        clause = 'YEAR(assets.purchase_date) = ?'
      end
      query = query.where(clause, key[i])
    end

    data = query.pluck(:asset_tag, 'asset_types.name', 'asset_subtypes.name', 'grant_purchases.pcnt_purchase_cost * assets.purchase_cost / 100.0').to_a

    {labels: DETAIL_LABELS, data: data, formats: DETAIL_FORMATS}
  end
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_actions
    @actions = [
        {
            type: :select,
            where: :group_by,
            values: [
                'Agency, Funding Program',
                'Agency, Funding Program, FY',

                'Funding Program, Agency',
                'Funding Program, Agency, FY',

                'Funding Program, FY',
                'Funding Program, FY, Agency',

                'FY, Funding Program',
                'FY, Funding Program, Agency',
            ],
            label: 'Group By'
        }
    ]
  end
  
  def get_data(organization_id_list, params)

    labels = []
    formats = []
    
    # Default scope orders by project_id
    query = Asset.unscoped.joins(:organization)
                .joins('INNER JOIN grant_purchases ON grant_purchases.asset_id = assets.id')
                .joins('INNER JOIN funding_sources ON grant_purchases.sourceable_id = funding_sources.id')
                .where(assets: {organization_id: organization_id_list})


    params[:group_by] = 'Funding Program, Agency' if params[:group_by].nil?
    # Add clauses based on params
    @clauses = []
    @group_by = params[:group_by] ? {group_by: params[:group_by]} : {}
    params[:group_by].split(',').each do |grp_clause|
      if grp_clause.include? 'Agency'
        labels << 'Agency'
        formats << :string
        clause = 'organizations.short_name'
      elsif grp_clause.include? 'Funding Program'
        labels << 'Funding Program'
        formats << :string
        clause = 'funding_sources.name'
      elsif grp_clause.include? 'FY'
        labels << 'FY'
        formats << :fiscal_year
        clause = 'YEAR(assets.purchase_date)'
      end
      @clauses << clause
      query = query.group(clause).order(clause)
    end

    # Generate queries for each column
    asset_counts = query.count
    costs = query.sum('grant_purchases.pcnt_purchase_cost * assets.purchase_cost / 100.0')

    data = []
    prev_header = row_data = nil
    if params[:group_by]
      # Add initial columns and ALI count to data
      asset_counts.each_with_index do |(k, v), i|
        row = [*k, v]
        row << costs.values[i].to_i

        if prev_header != row[0]

          # add previous row
          data << [prev_header, row_data] if prev_header

          row_data = [row]
        else
          row_data << row
        end

        prev_header = row[0]
      end
    end
    data << [prev_header, row_data] if prev_header

    formats[0] = :hidden

    return {labels: labels + COMMON_LABELS, data: data, formats: formats + COMMON_FORMATS, header_format: labels[0] == 'FY' ? :fiscal_year : :string}
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