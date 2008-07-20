################################
$:.push( File.dirname(__FILE__) + '/../../lib' )
$:.push( File.dirname(__FILE__) + '/../../../../sprout/lib' )

require 'sprout'
# Optionally load gems from the leading edge:
# set_sources 'http://gems.projectsprouts.org'
#sprout 'as3'
require 'sprout/as3_tasks'

# Configure the Project Model
project_model :model do |m|
  m.project_name      = 'JSONExample'
  m.background_color  = '#FFCC00'
  m.width             = 800
  m.height            = 600
  m.language          = 'mxml'
  m.libraries         << :corelib
end

desc 'Compile and debug the application'
debug :debug

desc 'Compile run the test harness'
unit :test

desc 'Compile the optimized deployment'
deploy :deploy

desc 'Create documentation for this project'
document :doc

# do |t|
#  t.doc_classes << 'JSONExample'
#  t.library_path << 'lib/corelib.swc'
#end

#desc 'Compile a SWC file for this project'
#deploy_swc :deploy

#desc 'Package up this project as a library gem'
#deploy_lib :deploy

#desc 'Compile, run and terminate the test harness'
#ci :cruise

# Make :debug the default (no-name) rake task
task :default => :debug
