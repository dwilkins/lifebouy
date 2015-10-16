$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'pry'

ENV["COVERAGE"] ||= 'off'

if ENV["COVERAGE"] == 'on'
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

# load in the support files, if any
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
Dir[File.expand_path(File.join('..', '..', 'lib', '**', '*.rb'), __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.profile_examples = 10
  config.mock_with  :rspec
  config.order      = 'random'
  config.filter_run :focus => true

  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "./spec/examples.txt"
  Kernel.srand config.seed
end
