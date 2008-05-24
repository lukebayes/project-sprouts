require 'rubygems'
require 'sprout'
require 'task/mxmlc'
require 'task/flash_player'
include PatternPark

############################################
# Uncomment and modify any of the following:
model = ProjectModel.instance
model.project_name  = '<%= project_name %>'

# Default Values:
# model.src_dir       = 'src'
# model.lib_dir       = 'lib'
# model.bin_dir       = 'bin'
# model.test_dir      = 'test'
# model.asset_dir     = 'assets'
model.language      = 'as3'
model.skin_dir      = File.join(model.asset_dir, 'img')

fcsh_ip             = "127.0.0.1"
fcsh_port           = 20569

############################################
# Launch the Application using Flash Player 9

desc "Compile and run main application"
task :run => :compile_main
task :default => :run

FlashPlayer.new(:run) do |t|
  t.version = 9
  t.swf = model.bin_dir + '/<%= project_name %>Application.swf'
end

############################################
# Launch the Test Suites using Flash Player 9

desc "Compile and run test suites"
task :test => [:compile_tests]

FlashPlayer.new(:test) do |t|
  t.version = 9
  t.swf = model.bin_dir + '/<%= project_name %>Runner.swf'
end

############################################
# Compile your Application using MXMLC

MXMLC.new(:compile_main) do |t|
  t.use_fcsh = false
  t.fcsh_ip = fcsh_ip
  t.fcsh_port = fcsh_port
  t.warnings = true
  t.default_background_color = '#FFFFFF'
  t.default_frame_rate = 24
  t.default_size = "600 400"
  t.input = model.src_dir + '/<%= project_name %>.as'
  t.output = model.bin_dir + '/<%= project_name %>Application.swf'
  t.source_path << model.skin_dir
  Dir[model.lib_dir + '/**'].each do |path|
    if(!path.index('unit')) # don't add unit test paths to main application
      t.source_path << path
    end
  end
end

############################################
# Compile your Application using MXMLC

MXMLC.new(:compile_tests) do |t|
  t.use_fcsh = false
  t.fcsh_ip = fcsh_ip
  t.fcsh_port = fcsh_port
  t.warnings = true
  t.default_background_color = '#FFFFFF'
  t.default_frame_rate = 24
  t.default_size = "800 450"
  t.input = model.src_dir + '/<%= project_name %>Runner.as'
  t.output = model.bin_dir + '/<%= project_name %>Runner.swf'
  t.source_path << model.src_dir
  t.source_path << model.test_dir
  t.source_path << model.skin_dir
  Dir[model.lib_dir + '/**'].each do |path|
    t.source_path << path
  end
end

############################################
# Stop running FCSHD process

desc "Stop the fcshd process"
task :stop_fcsh do |t|
  fcsh = FCSH.new(fcsh_ip, fcsh_port)
  fcsh.stop
end
