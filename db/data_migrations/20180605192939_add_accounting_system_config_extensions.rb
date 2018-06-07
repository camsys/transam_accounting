class AddAccountingSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: 'RehabilitationUpdateEvent', extension_name: 'TransamGlAccountableAssetEvent', active: true},
        {class_name: 'AssetsController', extension_name: 'TransamAccountingAssetsController', active: true},
        {class_name: 'Organization', extension_name: 'TransamAccountable', active: true},
        {class_name: 'Policy', extension_name: 'TransamAccountingPolicy', active: true},
        {class_name: 'Vendor', extension_name: 'TransamAccountingVendor', active: true}

    ]

    system_config_extensions.each do |extension|
      SystemConfigExtension.create!(extension)
    end
  end
end