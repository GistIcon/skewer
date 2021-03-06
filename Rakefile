require 'rubygems'

require 'bundler'

require 'cucumber'
require 'cucumber/rake/task'
require 'metric_fu'
require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
#require 'vagrant'

CLEAN.include ['coverage', 'target', '/tmp/skewer_test_code', '/tmp/more_skewer_test_code', '.skewer.json', '/tmp/skewer*']

RSPEC_PATTERN = 'spec/**/*spec*.rb'

Bundler::GemHelper.install_tasks

MetricFu::Configuration.run do |config|
  #define which metrics you want to use
  config.metrics  = [:saikuro, :flog, :flay, :reek, :roodi]
end

desc "fire up vagrant so we can test the plain ssh update script"
task :vagrant_destroy do
  env = Vagrant::Environment.new
  env.cli("destroy")
end

task :vagrant_up do
  env = Vagrant::Environment.new
  env.cli("up")
end

Cucumber::Rake::Task.new(:features, 'skewer') do |t|
  no_cloud = ENV['CLOUD'] ? '' : '--tags ~@cloud'
  t.cucumber_opts = "features --format pretty --tags ~@wip #{no_cloud}"
end

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = RSPEC_PATTERN
  t.rspec_opts = ['-I lib', '--color']
end

desc "Run all specs with rcov"
RSpec::Core::RakeTask.new("spec:coverage") do |t|
  t.rcov = true

  # The matcher *spec*.rb is used to invoke spec_helper.rb.
  # This makes sure that the RSpec tests get run from within rcov.
  # See spec/spec_helper.rb for more info.
  t.pattern = RSPEC_PATTERN

  t.rcov_opts = %w{--include lib -Ispec --exclude gems\/,spec\/,features\/}
  t.rspec_opts = ["-c"]
end

task :default => [:clean, :spec]
#task :features => :vagrant_up
