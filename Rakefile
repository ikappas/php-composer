require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run all specs'
RSpec::Core::RakeTask.new

desc 'Run RuboCop'
RuboCop::RakeTask.new

task(:default).clear
task default: [:rubocop, :spec]
