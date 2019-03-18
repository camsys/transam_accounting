class AddAccountingEngineNameSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: 'RehabilitationUpdateEvent', extension_name: 'TransamGlAccountableAssetEvent', active: true},
        {class_name: 'AssetsController', extension_name: 'TransamAccountingAssetsController', active: true},
        #{class_name: 'Organization', extension_name: 'TransamAccountable', active: true}, comment out temporarily as all orgs dont have COA
        {class_name: 'Policy', extension_name: 'TransamAccountingPolicy', active: true},
        {class_name: 'Vendor', extension_name: 'TransamAccountingVendor', active: true},
        {class_name: 'TransamAsset', extension_name: 'TransamValuable', active: true}

    ]

    system_config_extensions.each do |config|
      SystemConfigExtension.find_by(config).update!(engine_name: 'accounting')
    end
  end
end