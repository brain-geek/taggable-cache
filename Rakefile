# encoding: utf-8

begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue LoadError => e
  warn "[WARNING]: It is recommended that you use bundler during development: gem install bundler"
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec
