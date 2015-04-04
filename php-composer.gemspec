# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'composer/version'

Gem::Specification.new do |spec|
  spec.name             = 'php-composer'
  spec.version          = Composer::VERSION
  spec.authors          = ['Ioannis Kappas']
  spec.email            = ['ikappas@devworks.gr']

  spec.summary          = %q{PHP Composer Ruby Gem}
  spec.description      = %q{A ruby gem library for consistent interactions with php composer dependency manager.}
  spec.homepage         = %q{http://github.com/ikappas/php-composer/tree/master}
  spec.license          = 'MIT'

  spec.files            = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths    = ['lib']

  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = '>= 1.8'

  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'json-schema', '~> 2.5'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.28', '>= 0.28.0'
  spec.add_development_dependency 'simplecov', '~> 0.9'
end
