#$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'killjoy'
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "spec/examples.txt"
  #config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
