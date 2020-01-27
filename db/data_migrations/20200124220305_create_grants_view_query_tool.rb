class CreateGrantsViewQueryTool < ActiveRecord::DataMigration
  def up

    if SystemConfig.instance.default_fiscal_year_formatter == 'start_year'
      view_sql = <<-SQL
        CREATE OR REPLACE VIEW formatted_grants_view AS
        SELECT grants.id AS id, CONCAT(grant_num, ' : ', fy_year, ' : ', organizations.short_name, ' : Primary') AS grant_num
        FROM grants
        INNER JOIN organizations ON grants.owner_id = organizations.id
      SQL
    elsif SystemConfig.instance.default_fiscal_year_formatter == 'end_year'
      view_sql = <<-SQL
        CREATE OR REPLACE VIEW formatted_grants_view AS
        SELECT grants.id AS id, CONCAT(grant_num, ' : ', fy_year+1, ' : ', organizations.short_name, ' : Primary') AS grant_num
        FROM grants
        INNER JOIN organizations ON grants.owner_id = organizations.id
      SQL
    else
      view_sql = <<-SQL
        CREATE OR REPLACE VIEW formatted_grants_view AS
        SELECT grants.id AS id, CONCAT(grant_num, ' : ', substring(CAST(fy_year as CHAR(4)), 3, 2), IF(fy_year % 100 = 99, '00', substring(CAST((fy_year+1) as CHAR(4)), 3, 2)), ' : ', organizations.short_name, ' : Primary') AS grant_num
        FROM grants
        INNER JOIN organizations ON grants.owner_id = organizations.id
      SQL
    end

    ActiveRecord::Base.connection.execute view_sql

    QueryField.find_by(name: 'sourceable_id', label: 'Grant #').query_association_class.update!(table_name: 'formatted_grants_view')
  end
end