RSpec.configure do |config|

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_subtypes asset_types policies organizations organization_types]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
