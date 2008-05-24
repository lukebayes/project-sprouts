################################
require 'sprout'
# Optionally load gems from the leading edge:
# set_sources 'http://gems.projectsprouts.org'
#$:.push( File.dirname(__FILE__) + '/../../lib' )
sprout 'as3'
#require 'sprout/as3_tasks'

# Configure the Project Model
project_model :model do |m|
  m.project_name      = 'JSonExample'
  m.background_color  = '#FFCC00'
  m.width             = 800
  m.height            = 600
  m.language          = 'mxml'
  m.compiler_gem      = 'sprout-flex3sdk-tool'
  m.libraries         << :corelib
end

library :corelib

task :foo do 
  puts "FOO EXECUTED"
end

desc 'Compile and debug the application'
debug :debug => [:foo]

desc 'Compile run the test harness'
asunit :test

desc 'Compile the optimized deployment'
deploy :deploy

#desc 'Compile a SWC file for this project'
#deploy_swc :deploy

#desc 'Package up this project as a library gem'
#deploy_lib :deploy

#desc 'Compile run and terminate the test harness'
#ci :cruise

# Make :run the default (no-name) rake task
task :default => :debug
