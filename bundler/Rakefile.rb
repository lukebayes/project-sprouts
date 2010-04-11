require 'rubygems'
require 'bundler'

Bundler.setup

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rcov/rcovtask'

namespace :test do
 
  Rake::TestTask.new(:units) do |t|
    t.libs << "test/unit"
    t.test_files = FileList["test/unit/*_test.rb"]
    t.verbose = true
  end

  namespace :coverage do
    desc "Delete aggregate coverage data."
    task(:clean) { rm_f "coverage.data" }
  end

  desc "Aggregate code coverage for unit, functional and integration tests"
  task :coverage => "test:coverage:clean"

  # Hold collection in case we need it:
  #%w[unit functional integration].each do |target|
  %w[unit].each do |target|
    namespace :coverage do
      Rcov::RcovTask.new(target) do |t|
        t.libs = ["lib", "test"]
        t.test_files = FileList["test/#{target}/**/*_test.rb"]
        t.output_dir = ".coverage/#{target}"
        t.verbose = true
        t.rcov_opts << "--aggregate coverage.data --exclude .bundle"
      end
    end
    task :coverage => "test:coverage:#{target}"
  end
end

task :test => 'test:units'

namespace :torture do

  desc "Flog the Sprouts"
  task :flog do
    sh "find lib -name \**/*.rb | xargs flog"
  end

  desc "Flay the Sprouts"
  task :flay do
    sh "flay lib/**/*.rb"
  end
end

task :torture => ['torture:flog', 'torture:flay']

