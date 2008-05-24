require 'sprout'
# Optionally load gems from a server other than rubyforge:
# set_sources 'http://gems.projectsprouts.org'
sprout 'as2'

############################################
# Uncomment and modify any of the following:
Sprout::ProjectModel.setup do |model|
  model.project_name  = '<%= project_name %>'
  # Default Values:
  # model.src_dir       = 'src'
  # model.lib_dir       = 'lib'
  # model.swc_dir       = 'lib'
  # model.bin_dir       = 'bin'
  # model.test_dir      = 'test'
  # model.doc_dir       = 'doc'
  # model.asset_dir     = 'assets'
  model.language      = 'as2'
  model.output        = "#{model.bin_dir}/<%= project_name %>.swf"
  model.test_output   = "#{model.bin_dir}/<%= project_name %>Runner.swf"
  model.skin_output   = "#{model.skin_dir}/<%= project_name %>Skin.swf"
end

model = Sprout::ProjectModel.instance

############################################
# Set up remote library tasks
# the task name will be converted to a string
# and modified as follows sprout-#{name}-library
# unless you pass t.gem_name = 'full-sprout-name'
# For libraries that contain source code, the
# task name will also be the folder name that 
# will be added to ProjectModel.lib_dir
# For a complete list of available sprout gems:
# http://rubyforge.org/frs/?group_id=3688
# You can also search that list directly from a
# terminal as follows:
# gem search -r sprout-*library

library :asunit25

############################################
# Launch the application using the Flash Player
# NOTE: double-quoted strings in ruby enable
# runtime expression evaluation using the
# following syntax:
# "Some String with: #{variable}"

desc "Compile and run main application"
flashplayer :run => model.output

# Make 'run' the default task
task :default => :run

############################################
# Launch the test suites using the Flash Player

desc "Compile and run test suites"
flashplayer :test => model.test_output

############################################
# Compile the skin using SWFMill

swfmill model.skin_output do |t|
  t.input = "#{model.skin_dir}/<%= project_name %>Skin"
end

############################################
# Compile your application using mtasc
# Any library tasks that are set as 
# dependencies will automatically be added
# to the compiler source or swc paths

desc "Compile application"
mtasc model.output => [model.skin_output] do |t|
  t.main                      = true
  t.frame                     = 2
  t.input                     = "#{model.src_dir}/<%= project_name %>.as"
# t.class_path                << "#{model.lib_dir}/non-sprout-src-library"
end

############################################
# Compile test harness using mtasc
mtasc model.test_output => [:asunit25, model.skin_output] do |t|
  t.main                      = true
  t.input                     = "#{model.test_dir}/<%= project_name %>Runner.as"
  t.class_path                << model.src_dir
  t.class_path                << model.test_dir
# t.class_path                << "#{model.lib_dir}/non-sprout-src-library"
end
