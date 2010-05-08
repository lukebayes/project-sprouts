require File.join(File.dirname(__FILE__), 'test_helper')

# Must set before requiring generator libs.
TMP_ROOT     = File.join(File.dirname(__FILE__), "..", "tmp") unless defined?(TMP_ROOT)
PROJECT_NAME = "myproject" unless defined?(PROJECT_NAME)
app_root     = File.join(TMP_ROOT, PROJECT_NAME)

if defined?(APP_ROOT)
  APP_ROOT.replace(app_root)
else
  APP_ROOT = app_root
end

if defined?(RAILS_ROOT)
  RAILS_ROOT.replace(app_root)
else
  RAILS_ROOT = app_root
end

require 'rubigen'
require 'rubigen/helpers/generator_test_helper'

# Some generator-related assertions:
#   assert_generated_file(name, &block) # block passed the file contents
#   assert_directory_exists(name)
#   assert_generated_class(name, &block)
#   assert_generated_module(name, &block)
#   assert_generated_test_for(name, &block)
# The assert_generated_(class|module|test_for) &block is passed the 
# body of the class/module within the file
#   assert_has_method(body, *methods) # check that the body has a 
#   list of methods (methods with parentheses not supported yet)
#
# Other helper methods are:
#   app_root_files - put this in teardown to show files generated 
#   by the test method (e.g. p app_root_files)
#   bare_setup - place this in setup method to create the APP_ROOT 
#   folder for each test
#   bare_teardown - place this in teardown method to destroy the 
#   TMP_ROOT or APP_ROOT folder after each test

module Sprout::GeneratorTestHelper
  include RubiGen::GeneratorTestHelper

  def setup
    super
    bare_setup
  end

  def teardown
    super
    bare_teardown
  end

  protected

  def app_sources
    source = File.join(File.dirname(__FILE__),'..', '..', 'app_generators')
    [RubiGen::PathSource.new(:test, source)]
  end

end

