require 'sprout'
require 'sprout/flex4sdk/version'
#Comment out the above and uncomment the next line in order to use the flex3sdk
#require 'sprout/flex3sdk/version'

# Load gems from a server other than rubyforge:
set_sources 'http://gems.gemcutter.org'
sprout 'as3'

############################################
# Configure ProjectModel to be used by
# script/generate for appropriate bundles.

project_model :model do |m|
  m.project_name            = '<%= project_name %>'
  m.language                = 'mxml'

  m.compiler_gem_name       = 'sprout-flex4sdk-tool'
  #Comment out the above and uncomment the next line in order to use the flex3sdk
  #m.compiler_gem_name       = 'sprout-flex3sdk-tool'

  #if you want to use a specific version, uncomment and edit the following line
  #m.compiler_gem_version    = '>=4.0.0'

  m.input                   = 'src/<%= project_name %>.mxml'
  m.test_input              = 'src/FlexUnitApplication.mxml'
  #m.default_size           = '970 550'
  #m.default_background_color = '#ffffff'
  m.debug                   = true
  m.bin_dir                 = 'bin'
  m.output                  = "#{m.bin_dir}/<%= project_name.downcase %>.swf"
  m.debug_output            = "#{m.bin_dir}-debug/<%= project_name.downcase %>.swf"
  m.air_input               = m.output
  m.air_output_dir          = "package/<%= project_name %>.air"
  m.asset_dir               = 'src/assets'
  m.source_path             = []
  m.source_path             << 'src'
  m.source_path             << m.asset_dir
  m.library_path            = "lib"
  m.air_config_file         = []
  m.air_config_file         << File.join(Sprout::Sprout.gem_file_cache('sprout-flex4sdk-tool', Sprout::Flex4SDK::VERSION::STRING), 'archive','frameworks','air-config.xml')
  #Comment out the above and uncomment the next line in order to use the flex3sdk
#  m.air_config_file         << File.join(Sprout::Sprout.gem_file_cache('sprout-flex3sdk-tool', Sprout::Flex4SDK::VERSION::STRING), 'archive','frameworks','air-config.xml')
end

model = Sprout::ProjectModel.instance

### Basic tasks ###

desc 'Compile the optimized deployment'
mxmlc :compile do |t|
  t.gem_name                  = model.compiler_gem_name
  t.warnings                  = true
  t.source_path               = model.source_path
  t.input                     = model.input
  t.optimize                  = true
  t.debug                     = false
  t.output                    = model.output
  t.load_config               = model.air_config_file
  #t.default_size             = '800 600'
  #t.default_background_color = "#FFFFFF"

  #added lib directory as a library path
  #so that swc files can be dropped in lib
  #and automatically picked up
  t.library_path              << model.library_path
end

desc 'Compile the app for debugging'
mxmlc :compile_debug do |t|
  t.gem_name                  = model.compiler_gem_name
  t.warnings                  = true
  t.source_path               = model.source_path
  t.input                     = model.input
  t.optimize                  = true
  t.debug                     = true
  t.output                    = model.debug_output
  t.verbose_stacktraces       = true
  t.load_config               = model.air_config_file
  #t.default_size             = '800 600'
  #t.default_background_color = "#FFFFFF"

  #added lib directory as a library path
  #so that swc files can be dropped in lib
  #and automatically picked up
  t.library_path              << model.library_path
end

############################################
# Configure :debug
# http://projectsprouts.org/rdoc/classes/Sprout/ADLTask.html
desc 'Rake task to debug in air runtime'
adl :debug => [:compile_debug] do |t|
  t.root_directory              = "."
  t.application_descriptor      = "src/<%= project_name %>-Debug-app.xml"
  t.gem_name                    = model.compiler_gem_name
  # Uncomment this in order to use some features
  # see http://projectsprouts.org/rdoc/classes/Sprout/ADLTask.html#M000431
  # t.pubid                     = ""
end

# set :debug as the :default task
task :default => :debug

############################################
# Configure :run
# http://projectsprouts.org/rdoc/classes/Sprout/ADLTask.html

desc 'Rake task to run in air runtime'
adl :run => [:compile] do |t|
  t.root_directory            = "."
  t.application_descriptor    = "src/<%= project_name %>-app.xml"
  t.gem_name                  = model.compiler_gem_name
  # Uncomment this in order to use some features
  # see http://projectsprouts.org/rdoc/classes/Sprout/ADLTask.html#M000431
  # t.pubid                     = ""
end


############################################
# Configure :certificate
# http://projectsprouts.org/rdoc/classes/Sprout/AsDocTask.html
asdoc :doc => [:compile] do |t|
  t.source_path               = model.source_path
  t.library_path              << model.library_path
  t.doc_classes               << '<%= project_name %>'
  t.main_title                = '<%= project_name %>'
  t.footer                    = ''
  t.load_config               = model.air_config_file
  t.output                    = 'doc'
  t.gem_name                  = model.compiler_gem_name
end

############################################
# Configure :certificate
# http://projectsprouts.org/rdoc/classes/Sprout/ADTCertTask.html

# have a look at the url in order to learn more about the possible options
adt_cert :certificate do |t|
  t.cn                        = "Common name"
  t.keytype                   = "1024-RSA"
  t.keystore                  = "cert/cert.p12"
  t.keypass                   = "secret"
  t.gem_name                  = model.compiler_gem_name
end


############################################
# Configure :package
# http://projectsprouts.org/rdoc/classes/Sprout/ADTTask.html

desc 'Rake task package an .air file'
adt :package => [:compile ] do |t|
  t.storetype               = "PKCS12"
  #change keystore and storepass if you use your own key
  t.keystore                = "cert/cert.p12"
  t.storepass               = "secret"
  t.output                  = model.air_output_dir
  t.application_descriptor  = "src/<%= project_name %>-app.xml"
  t.files                   = [ model.output, model.asset_dir ]
  t.gem_name                = model.compiler_gem_name
end

