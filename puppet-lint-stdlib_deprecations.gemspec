# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puppet-lint/plugins/version'

Gem::Specification.new do |spec|
  spec.name          = 'puppet-lint-stdlib_deprecations'
  spec.version       = StdlibDeprecations::VERSION
  spec.authors       = ['Puppet, Inc.']
  spec.files         = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.summary       = 'A puppet-lint plugin to aid your puppetlabs-stdlib 9.x upgrade.'
  spec.description   = <<-DESC
    Helps to detect deprecated, removed and non-namespaced puppetlabs-stdlib functions and datatypes during your upgrade to puppetlabs-stdlib 9.x,
    and puppet 8.
  DESC
  spec.homepage      = 'https://github.com/puppetlabs/puppet-lint-stdlib_deprecations'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7')

  spec.add_runtime_dependency 'puppet-lint', '~> 4.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
