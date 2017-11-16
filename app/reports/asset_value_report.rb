class AssetValueReport < AbstractReport

  COMMON_LABELS = ['Quantity', 'Cost Basis', 'Accumulated Depr.', 'Book Value']
  COMMON_FORMATS = [:integer, :currency, :currency, :currency]
  DETAIL_LABELS = ['Agency', 'Type', 'Subtype', 'Asset Tag', 'Cost Basis', 'Accumulated Depr', 'Book Value']
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
    
    data = query.pluck(*['organizations.short_name', 'asset_types.name', 'asset_subtypes.name', 'assets.asset_tag', 'assets.depreciation_purchase_cost', 'assets.depreciation_purchase_cost-assets.book_value', 'assets.book_value']).to_a

    {labels: DETAIL_LABELS, data: data, formats: DETAIL_FORMATS}
  end
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_actions
    @actions = [{type: :check_box_collection,
                 group: :group_by,
                 values: [:by_agency, :by_type, :by_subtype]}]
  end
  
  def get_data(organization_id_list, params)

    labels = []
    formats = []
    
    # Default scope orders by project_id
    query = Asset.operational.joins(:organization, :asset_type, :asset_subtype).where(organization_id: organization_id_list)
    rehabs = RehabilitationUpdateEvent.unscoped.joins(asset: [:organization, :asset_type, :asset_subtype]).where(assets: {organization_id: organization_id_list})
    expenditures = Expenditure.joins(assets: [:organization, :asset_type, :asset_subtype]).where(assets: {organization_id: organization_id_list})

    params[:group_by] = ['by_agency', 'by_type', 'by_subtype'] if params[:group_by].nil?
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
      query = query.group(clause).order(clause)
      rehabs = rehabs.group(clause).order(clause)
      expenditures = expenditures.group(clause).order(clause)
    end

    # Generate queries for each column
    asset_counts = query.count
    costs = query.sum(:depreciation_purchase_cost)
    rehabs = rehabs.sum(:total_cost)
    expenditures = expenditures.sum(:amount)
    book_values = query.sum(:book_value)
    
    data = []
    if params[:group_by]
      # Add initial columns and ALI count to data
      asset_counts.each do |k, v|
        data << [*k, v]
      end
      # Add cost
      costs.each_with_index do |(k, v), i|
        data[i] << v + rehabs[k].to_i + expenditures[k].to_i
      end
      # Add accumulated depr and book value,
      book_values.each_with_index do |(k, v), i|
        data[i] << data[i][-1] - v
        data[i] << v
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