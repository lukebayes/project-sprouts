################################
require 'sprout'
sprout 'sprout-as3-bundle'

# Set up the Project Model to carry arbitrary values:
class Sprout::ProjectModel 
  attr_accessor :input,
                :output,
                :test_input,
                :test_output,
                :air_input,
                :air_output
end

# Configure those new values on the Project Model
Sprout::ProjectModel.setup do |m|
  m.input       = "#{m.src_dir}/JSONExample.mxml"
  m.output      = "#{m.bin_dir}/JSONExample.swf"
  m.test_input  = "#{m.test_dir}/SomeProjectRunner.mxml"
  m.test_output = "#{m.bin_dir}/SomeProjectRunner.swf"
  m.air_input   = m.output
  m.air_output  = "#{m.bin_dir}/JSONExample.air"
end

# Expose the Project Model instance locally to this file
model = Sprout::ProjectModel.instance

# Initialize requisite library gems
library :corelib
library :asunit3

mxmlc model.output => [:corelib] do |t|
  t.input         = model.input
  t.optimize      = true
  t.default_size  = '800 600'
  t.default_background_color = "#FFFFFF"
end

# Alias the compile task so that we can 
# see it when running rake -T and initiate
# just compilation easily.
desc "Compile application using mxmlc"
task :compile => model.output

desc "Run application using the Adobe Flash Player"
flashplayer :run => model.output

mxmlc model.test_output => [:corelib, :asunit3] do |t|
  t.input               = model.test_input
  t.default_size        = '1000 600'
  t.verbose_stacktraces = true
end

adt :package => model.output do |t|
  t.storetype = "PKCS12"
  t.keystore = "cert.p12"
  t.output = model.air_output
  t.application_descriptor = "src/SomeProject-app.xml"
  t.files = [ "assets", "skins" ]
end


desc "Run the test harness"
flashplayer :test => model.test_output

# Make :run the default (no-name) rake task
task :default => :run
