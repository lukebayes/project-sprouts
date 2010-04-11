require 'rubygems'
require 'bundler'

Bundler.setup

require 'rake'
require 'rake/clean'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

