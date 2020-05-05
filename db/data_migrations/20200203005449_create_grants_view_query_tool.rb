class CreateGrantsViewQueryTool < ActiveRecord::DataMigration
  def up

    if SystemConfig.instance.default_fiscal_year_formatter == 'start_year'
      view_sql = <<-SQL
        CREATE OR REPLACE VIEW formatted_grants_view AS
        SELECT grants.id AS id, CONCAT(grant_num, ' : ', fy_year, ' : ', organizations.short_name, ' : Primary') AS grant_num
        FROM grants
        INNER JOIN organizations ON grants.owner_id = organizations.id;
      SQL
    elsif SystemConfig.instance.default_fiscal_year_formatter == 'end_year'
      view_sql = <<-SQL
        CREATE OR REPLACE VIEW formatted_grants_view AS
        SELECT grants.id AS id, CONCAT(grant_num, ' : ', fy_year+1, ' : ', organizations.short_name, ' : Primary') AS grant_num
        FROM grants
        INNER JOIN organizations ON grants.owner_id = organizations.id;
      SQL
    else
      view_sql = <<-SQL
        CREATE OR REPLACE VIEW formatted_grants_view AS
        SELECT grants.id AS id, CONCAT(grant_num, ' : ', IF(fy_year % 100 < 10, CONCAT('0',fy_year % 100), fy_year % 100), '-' ,IF(fy_year % 100 = 99, '00', IF(fy_year % 100 + 1 < 10, CONCAT('0',fy_year % 100 + 1), fy_year % 100 + 1)), ' : ', organizations.short_name, ' : Primary') AS grant_num
        FROM grants
        INNER JOIN organizations ON grants.owner_id = organizations.id;
      SQL
    end

    ActiveRecord::Base.connection.execute view_sql

    QueryField.find_by(name: 'sourceable_id', label: 'Grant #').query_association_class.update!(table_name: 'formatted_grants_view')
  end
end