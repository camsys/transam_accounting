module TransamAccounting
  class Engine < ::Rails::Engine
    # Add a load path for this specific Engine
    config.autoload_paths += %W(#{Rails.root}/app/calculators)

    # Append migrations from the engine into the main app    
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
