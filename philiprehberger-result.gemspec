# frozen_string_literal: true

require_relative 'lib/philiprehberger/result/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-result'
  spec.version = Philiprehberger::Result::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Result type with Ok/Err, map, flat_map, and pattern matching'
  spec.description = 'A lightweight Result type for Ruby with Ok and Err variants, ' \
                     'monadic map/flat_map operations, unwrap helpers, and Ruby 3.1+ ' \
                     'pattern matching support.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-result'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-result'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-result/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-result/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
