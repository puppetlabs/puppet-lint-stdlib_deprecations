# frozen_string_literal: true

require 'rspec'
require 'simplecov'
require 'puppet-lint'
require 'rspec/its'

if ENV['COVERAGE'] == 'yes'
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]

  SimpleCov.start do
    track_files 'lib/puppet-lint/**/*.rb'
    add_filter 'lib/puppet-lint/plugins/version.rb'
    add_filter '/spec'
  end
end

PuppetLint::Plugins.load_spec_helper

# Additional RSpec configuration
RSpec.configure do |c|
  # Example configuration
  c.mock_with :rspec
end
