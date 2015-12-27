RSpec.configure do |config|

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets policies organizations]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
