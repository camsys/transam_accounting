$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transam_accounting/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transam_accounting"
  s.version     = TransamAccounting::VERSION
  s.authors     = ["Julian Ray"]
  s.email       = ["jray@camsys.com"]
  s.homepage    = "http://www.camsys.com"
  s.summary     = "Accounting Extensions for TransAM."
  s.description = "Accounting Mangagement  for TransAM."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  
  s.add_dependency 'rails', '>=4.0.9'
  s.add_dependency 'transam_core'

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"  
  s.add_development_dependency "mysql2"
  s.add_development_dependency "cucumber-rails"
end
