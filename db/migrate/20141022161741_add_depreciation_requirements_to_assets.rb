class AddDepreciationRequirementsToAssets < ActiveRecord::Migration
  def change
    # an asset is depreciable or not
    add_column    :assets, :property_type, :boolean, :default => true, :after => :estimated_value

    # start date of depreciation (usually same as in_service_date)
    add_column    :assets, :depreciation_start_date, :date, :after => :property_type

    # date that the book value of the asset is calculated for (usually last day of FY)
    add_column    :assets, :current_depreciation_date, :date, :after => :depreciation_start_date

    # depreciated value of the asset on the asset
    add_column    :assets, :book_value, :integer, :after => :current_depreciation_date

    # salvage value of the asset
    add_column    :assets, :salvage_value, :integer, :after => :book_value

  end
end
