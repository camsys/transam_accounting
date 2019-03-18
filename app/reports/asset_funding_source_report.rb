class AssetFundingSourceReport < AbstractReport

  include FiscalYearHelper

  COMMON_LABELS = ['# Assets', 'Cost (Purchase)']
  COMMON_FORMATS = [:integer, :currency]
  DETAIL_LABELS = ['Asset ID', 'Category', 'Class', 'Type', 'Subtype', 'Cost (Purchase)']
  DETAIL_FORMATS = [:string, :string, :string, :string, :string, :currency]

  def self.get_detail_data(organization_id_list, params)
    query = TransitAsset.unscoped.joins([{transam_asset: [:organization, :asset_subtype]}, :fta_asset_category, :fta_asset_class])
                .joins('LEFT JOIN fta_vehicle_types ON transit_assets.fta_type_id = fta_vehicle_types.id AND transit_assets.fta_type_type="FtaVehicleType"')
                .joins('LEFT JOIN fta_equipment_types ON transit_assets.fta_type_id = fta_equipment_types.id AND transit_assets.fta_type_type="FtaEquipmentType"')
                .joins('LEFT JOIN fta_support_vehicle_types ON transit_assets.fta_type_id = fta_support_vehicle_types.id AND transit_assets.fta_type_type="FtaSupportVehicleType"')
                .joins('LEFT JOIN fta_facility_types ON transit_assets.fta_type_id = fta_facility_types.id AND transit_assets.fta_type_type="FtaFacilityType"')
                .joins('LEFT JOIN fta_track_types ON transit_assets.fta_type_id = fta_track_types.id AND transit_assets.fta_type_type="FtaTrackType"')
                .joins('LEFT JOIN fta_guideway_types ON transit_assets.fta_type_id = fta_guideway_types.id AND transit_assets.fta_type_type="FtaGuidewayType"')
                .joins('LEFT JOIN fta_power_signal_types ON transit_assets.fta_type_id = fta_power_signal_types.id AND transit_assets.fta_type_type="FtaPowerSignalType"')
                .joins('LEFT JOIN grant_purchases  ON grant_purchases.transam_asset_id = transam_assets.id AND grant_purchases.sourceable_type="FundingSource"')
                .joins('LEFT JOIN funding_sources ON grant_purchases.sourceable_id = funding_sources.id')
                .where(transam_assets: {organization_id: organization_id_list})

    key = params[:key].split('-').map{|x| x.to_s.tr('_', ' ')}

    params[:group_by] = 'Funding Program, Agency' if params[:group_by].nil?
    params[:group_by].split(',').each_with_index do |grp_clause, i|
      if grp_clause.include? 'Agency'
        clause = 'organizations.short_name = ?'
      elsif grp_clause.include? 'Funding Program'
        clause = 'funding_sources.name = ?'
      elsif grp_clause.include? 'Year of Purchase'
        start_of_fy = DateTime.strptime("#{SystemConfig.instance.start_of_fiscal_year}-1900", "%m-%d-%Y").to_date
        clause = "IF(DAYOFYEAR(transam_assets.purchase_date) < DAYOFYEAR('#{start_of_fy}'), YEAR(transam_assets.purchase_date)-1, YEAR(transam_assets.purchase_date)) = ?"
      end

      if key[i] == 'No Funding Program Data'
        query = query.where('funding_sources.name IS NULL')
      else
        query = query.where(clause, key[i])
      end

    end

    data = query.pluck(:asset_tag, 'fta_asset_categories.name', 'fta_asset_classes.name', 'COALESCE(fta_vehicle_types.name, fta_equipment_types.name, fta_support_vehicle_types.name, fta_facility_types.name, fta_track_types.name, fta_guideway_types.name, fta_power_signal_types.name)', 'asset_subtypes.name', 'IF(grant_purchases.pcnt_purchase_cost IS NULL, transam_assets.purchase_cost, grant_purchases.pcnt_purchase_cost * transam_assets.purchase_cost / 100.0)').to_a

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
                "Agency, Funding Program, Year of Purchase",

                'Funding Program, Agency',
                "Funding Program, Agency, Year of Purchase",

                "Funding Program, Year of Purchase",
                "Funding Program, Year of Purchase, Agency",

                "Year of Purchase, Funding Program",
                "Year of Purchase, Funding Program, Agency",
            ],
            label: 'Group By'
        }
    ]
  end

  def get_data(organization_id_list, params)

    labels = []
    formats = []

    # Default scope orders by project_id
    query = TransamAsset.unscoped.joins(:organization)
                .joins('LEFT JOIN grant_purchases  ON grant_purchases.transam_asset_id = transam_assets.id AND grant_purchases.sourceable_type="FundingSource"')
                .joins('LEFT JOIN funding_sources ON grant_purchases.sourceable_id = funding_sources.id')
                .where(organization_id: organization_id_list)


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
        clause = 'IF(funding_sources.name IS NULL, "No Funding Program Data",funding_sources.name)'
      elsif grp_clause.include? 'Year of Purchase'
        labels << 'Year of Purchase'
        formats << :fiscal_year
        start_of_fy = DateTime.strptime("#{SystemConfig.instance.start_of_fiscal_year}-1900", "%m-%d-%Y").to_date
        clause = "IF(DAYOFYEAR(transam_assets.purchase_date) < DAYOFYEAR('#{start_of_fy}'), YEAR(transam_assets.purchase_date)-1, YEAR(transam_assets.purchase_date))"
      end
      @clauses << clause

      if grp_clause.include? 'Funding Program'
        query = query.group(clause).order('funding_sources.name IS NULL').order(clause)
      else
        query = query.group(clause).order(clause)
      end
    end

    # Generate queries for each column
    asset_counts = query.count
    costs = query.sum('IF(grant_purchases.pcnt_purchase_cost IS NULL, transam_assets.purchase_cost, grant_purchases.pcnt_purchase_cost * transam_assets.purchase_cost / 100.0)')

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

    return {labels: labels + COMMON_LABELS, data: data, formats: formats + COMMON_FORMATS, header_format: labels[0] == 'Year of Purchase' ? :fiscal_year : :string}
  end

  def get_key(row)
    row.slice(0, @clauses.count).map{|r| r.to_s.tr(' ','_')}.join('-')
  end

  def get_detail_path(id, key, opts={})
    ext = opts[:format] ? ".#{opts[:format]}" : ''
    "#{id}/details#{ext}?key=#{key}&#{@group_by.to_query}"
  end

  def get_detail_view
    "generic_report_detail"
  end

end