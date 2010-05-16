require File.join(File.dirname(__FILE__), 'test_helper')
require 'rubigen'

# Some generator-related assertions:
#   assert_generated_file(name, &block) # block passed the file contents
#   assert_directory_exists(name)
#   assert_generated_class(name, &block)
#   assert_generated_module(name, &block)
#   assert_generated_test_for(name, &block)
#
# The assert_generated_(class|module|test_for) &block is passed the 
# body of the class/module within the file
#
#   assert_has_method(body, *methods) # check that the body has a 
#   list of methods (methods with parentheses not supported yet)
#
# Other helper methods are:
#   app_root_files - put this in teardown to show files generated 
#   by the test method (e.g. p app_root_files)
#
#   bare_setup - place this in setup method to create the app_root 
#   folder for each test
#
#   bare_teardown - place this in teardown method to destroy the 
#   tmp_root folder after each test

module Sprout::GeneratorTestHelper

  attr_accessor :tmp_root
  attr_accessor :app_root

  def setup
    super
    @tmp_root = File.join 'test', 'fixtures', 'generators', 'tmp'
    @app_root = File.join tmp_root, 'myproject'
    bare_setup
  end

  def teardown
    super
    bare_teardown
  end

  protected

  def app_sources
    source = 'app_generators'
    [RubiGen::PathSource.new(:test, source)]
  end

  # Runs the create command (like the command line does)
  def run_generator(name, params, sources, options = {})
    # TODO: Create/Configure to use tmp_dir
    generator = build_generator(name, params, sources, options)
    silence_generator do
      generator.command(:create).invoke!
    end
    generator
  end

  # Instatiates the Generator
  def build_generator(name, params, sources, options)
    @stdout ||= StringIO.new
    options.merge!(:collision => :force)  # so no questions are prompted
    options.merge!(:stdout => @stdout)  # so stdout is piped to a StringIO
    if sources.is_a?(Symbol)
      if sources == :app
        RubiGen::Base.use_application_sources!
      else
        RubiGen::Base.use_component_sources!
      end
    else
      RubiGen::Base.reset_sources
      RubiGen::Base.prepend_sources(*sources) unless sources.blank?
    end
    RubiGen::Base.instance(name, params, options)
  end

  # Silences the logger temporarily and returns the output as a String
  def silence_generator
    logger_original      = RubiGen::Base.logger
    myout                = StringIO.new
    RubiGen::Base.logger = RubiGen::SimpleLogger.new(myout)
    yield if block_given?
    RubiGen::Base.logger = logger_original
    myout.string
  end

  # asserts that the given file was generated.
  # the contents of the file is passed to a block.
  def assert_generated_file(path)
    assert_file_exists(path)
    File.open("#{app_root}/#{path}") do |f|
      yield f.read if block_given?
    end
  end

  # asserts that the given file exists
  def assert_file_exists(path)
    assert File.exists?("#{app_root}/#{path}"),"The file '#{path}' should exist"
  end

  # asserts that the given directory exists
  def assert_directory_exists(path)
    assert File.directory?("#{app_root}/#{path}"),"The directory '#{path}' should exist"
  end

  # asserts that the given class source file was generated.
  # It takes a path without the <tt>.rb</tt> part and an optional super class.
  # the contents of the class source file is passed to a block.
  def assert_generated_class(path,parent=nil)
    path=~/\/?(\d+_)?(\w+)$/
    class_name=$2.camelize
    assert_generated_file("#{path}.rb") do |body|
      assert body=~/class #{class_name}#{parent.nil? ? '':" < #{parent}"}/,"the file '#{path}.rb' should be a class"
      yield body if block_given?
    end
  end

  # asserts that the given module source file was generated.
  # It takes a path without the <tt>.rb</tt> part.
  # the contents of the class source file is passed to a block.
  def assert_generated_module(path)
    path=~/\/?(\w+)$/
    module_name=$1.camelize
    assert_generated_file("#{path}.rb") do |body|
      assert body=~/module #{module_name}/,"the file '#{path}.rb' should be a module"
      yield body if block_given?
    end
  end

  # asserts that the given unit test was generated.
  # It takes a name or symbol without the <tt>test_</tt> part and an optional super class.
  # the contents of the class source file is passed to a block.
  def assert_generated_test_for(name, parent="Test::Unit::TestCase")
    assert_generated_class "test/test_#{name.to_s.underscore}", parent do |body|
      yield body if block_given?
    end
  end

  # asserts that the given methods are defined in the body.
  # This does assume standard rails code conventions with regards to the source code.
  # The body of each individual method is passed to a block.
  def assert_has_method(body,*methods)
    methods.each do |name|
      assert body=~/^  def #{name.to_s}\n((\n|   .*\n)*)  end/,"should have method #{name.to_s}"
      yield( name, $1 ) if block_given?
    end
  end
  
  def app_root_files
    Dir[app_root + '/**/*']
  end

  def rubygem_folders
    %w[bin examples lib test]
  end

  def rubygems_setup
    bare_setup
    rubygem_folders.each do |folder|
      Dir.mkdir("#{app_root}/#{folder}") unless File.exists?("#{app_root}/#{folder}")
    end
  end

  def rubygems_teardown
    bare_teardown
  end

  def bare_setup
    FileUtils.mkdir_p(app_root)
    @stdout = StringIO.new
  end

  def bare_teardown
    # Ensure we don't inadvertently rm_rf some important
    # folder that we accidentally set tmp_root to - 
    # like '/' for instance...
    if(!tmp_root.nil? && tmp_root.include?('fixtures'))
      FileUtils.rm_rf tmp_root
    end
  end
  
end

