# -*- encoding: utf-8 -*-
require 'rake'

$:.push File.expand_path('../lib', __FILE__)
require 'composer'

Gem::Specification.new do |spec|
  spec.name             = 'php-composer'
  spec.version          = Composer::GEM_VERSION
  spec.authors          = ['Ioannis Kappas']
  spec.email            = ['ikappas@devworks.gr']

  spec.summary          = %q{PHP Composer Ruby Gem}
  spec.description      = %q{A ruby gem library for consistent interactions with php composer dependency manager.}
  spec.homepage         = %q{http://github.com/ikappas/php-composer/tree/master}
  spec.license          = 'MIT'

  spec.files            = FileList['lib/**/*.rb', 'LICENSE.txt', 'README.md']
  spec.test_files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths    = ['lib']

  spec.required_ruby_version = '>= 2.1.7'
  spec.required_rubygems_version = '>= 1.8'

  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'json-schema', '~> 2.5'
  spec.add_runtime_dependency 'php-composer-semver', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.35', '>= 0.35.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.3', '>= 1.3.1'
  spec.add_development_dependency 'coveralls', '~> 0.8.2'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'factory_girl', '~> 4.5.0'
end
