class CleanupExpenseTypes < ActiveRecord::DataMigration
  def up
    # clean out duplicates
    ExpenseType.pluck(:name).uniq.each do |expense_name|
      expense_type = ExpenseType.find_by(name: expense_name)
      ExpenseType.where(name: expense_name).where.not(id: expense_type.id).delete_all
    end

    #add expense types if they are none
    if ExpenseType.count == 0
      [
        'Air Quality',
        'Bus Inspections',
        'Design',
        'Production',
        'Diesel and Fuel',
        'Electric',
        'Environmental and Professional Services',
        'Installations/Repairs/Renovations',
        'Legal/Services/Consultation/Training',
        'Other',
        'Phone',
        'Rehab',
        'Soil and Groundwater',
        'Storage Tanks',
        'Travel/Seminars/Conferences',
        'Project Management'
      ].each do |type|
        ExpenseType.create!(name: type, description: type, active: true)
      end
    end
  end
end