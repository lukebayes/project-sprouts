require 'rubygems'
require 'bundler'

# Hack this dir onto path for Ruby 1.9.2
# support:
test_package = File.expand_path(File.join(File.dirname(__FILE__), 'test'))
$: << test_package unless $:.include? test_package

Bundler.require

require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'

require File.dirname(__FILE__) + '/lib/sprout/version'

Rake::RDocTask.new do |rdoc|
  rdoc.title = "Project Sprouts v.#{Sprout::VERSION::STRING}"
  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = "Sprout::Sprout"
  rdoc.rdoc_files.include("README.textile", "lib/**/*.rb")
end

CLEAN.add('rdoc')

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

  # Apparently, rcov does not work on Windows or Ubuntu?
  # Hide these tasks so that we can at least
  # run the others...
  if(RUBY_PLATFORM =~ /darwin/i)
    require 'rcov/rcovtask'

    CLEAN.add('coverage.data')
    CLEAN.add('.coverage')

    # Hold collection in case we need it:
    #%w[unit functional integration].each do |target|
    %w[unit].each do |target|
      namespace :coverage do
        Rcov::RcovTask.new(target) do |t|
          t.libs = ["lib", "test"]
          t.test_files = FileList["test/#{target}/**/*_test.rb"]
          t.output_dir = ".coverage/#{target}"
          t.verbose = true
          t.rcov_opts = ["--sort coverage",
                         "--aggregate coverage.data", 
                         "--exclude .bundle",
                         "--exclude .gem",
                         "--exclude errors.rb",
                         "--exclude progress_bar.rb"]
        end
      end
      task :coverage => "test:coverage:#{target}"
    end
  end

  namespace :torture do
    desc "Flog the Sprouts"
    task :flog do
      puts "--------------------------"
      puts "Flog Report:"
      message =<<EOM
According to Jake Scruggs at: http://bit.ly/3QrvW

Score of    Means
0-10        Awesome
11-20       Good enough
21-40       Might need refactoring
41-60       Possible to justify
61-100      Danger
100-200     Whoop, whoop, whoop
200 +       Someone please think of the children
EOM
      puts message
      puts ""

      sh "find lib -name '*.rb' | xargs flog"
    end

    desc "Flay the Sprouts"
    task :flay do
      puts "--------------------------"
      puts "Flay Report:"
      sh "flay lib/**/*.rb"
    end
  end

  desc "Run all tortuous reports"
  task :torture => ['torture:flog', 'torture:flay']

end

task :test => 'test:units'

desc "Run all tests and reports"
task :cruise => [:test, 'test:coverage', 'test:torture']

