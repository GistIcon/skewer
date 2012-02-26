require 'rubygems'

require 'bundler'

require 'cucumber'
require 'cucumber/rake/task'
require 'metric_fu'
require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'vagrant'

CLEAN.include ['coverage', 'target', '/tmp/skewer_test_code', '/tmp/more_skewer_test_code', '.skewer.json']

Bundler::GemHelper.install_tasks

MetricFu::Configuration.run do |config|
  #define which metrics you want to use
  config.metrics  = [:saikuro, :flog, :flay, :reek, :roodi, :rcov]
  #config.graphs   = [:flog, :flay, :stats]
end

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern ='spec/**/*.rb'
  t.rspec_opts = ['-I lib', '--color']
end

desc "fire up vagrant so we can test the plain ssh update script"
task :bumsrush do 
  env = Vagrant::Environment.new
  env.cli("destroy")
end

task :vagrant do 
  env = Vagrant::Environment.new
  env.cli("up")
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty --tags=~@wip"
end

task :default => [:clean, :spec, :features]
task :features => :vagrant
task :clean => :bumsrush
