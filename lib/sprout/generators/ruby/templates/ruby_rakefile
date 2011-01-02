require 'rubygems'
require 'bundler'
Bundler.require

require 'rake/testtask'

# Hack this dir onto path for Ruby 1.9.2
# support:
test_package = File.expand_path(File.join(File.dirname(__FILE__), 'test'))
$: << test_package unless $:.include? test_package

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.libs << "test/unit"
    t.test_files = FileList["test/unit/*_test.rb"]
    t.verbose = true
  end
end

task :test => 'test:units'

