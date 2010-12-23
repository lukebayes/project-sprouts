
##
# A collection of custom assertions and helper methods
# to take some of the suck out of testing functionality
# that is based on Sprout features.
#
# Include this module into your test cases to make
# testing Sprout tools easier.
#
#   require 'sprout/test/sprout_test_helper'
#
#   class SomeTestCase < Test::Unit::TestCase
#     include Sprout::TestHelper
#
#     def setup
#       super
#       # do something
#     end
#
#     def teardown
#       super
#       # do something
#     end
#
#     def test_something
#       assert_file File.join(fixtures, 'some_file') do |f|
#         assert_matches /Fred/, f
#       end
#     end
#   end
#
module Sprout::TestHelper

  ##
  # The name of the folder that should contain
  # fixture data.
  FIXTURES_NAME = 'fixtures'

  # Gives us the ability to hide RubyGem output from
  # our test results...
  include Gem::DefaultUserInteraction

  ##
  # Add the skip method that was introduced in Ruby 1.9.1 Test::Unit
  # This doesn't really work all that well...
  if(RUBY_VERSION == '1.8.7')
    def skip message=""
      puts
      puts ">> SproutTestCase.skip called from: #{caller[0]} ( #{message} )"
    end
  end

  ##
  # @return [Dir] Path to a fixtures folder that is next to
  # the text case that calls this method.
  def fixtures from=nil
    @fixtures ||= find_fixtures(from || Sprout.file_from_caller(caller.first))
  end

  ##
  # Override the setup method in order to record the 
  # working directory before the test method runs.
  def setup
    super
    @start_path = Dir.pwd
  end

  ##
  # Override the teardown method in order to perform
  # systemic cleanup work like, clearing lingering rake tasks,
  # and removing temporary folders.
  def teardown
    super
    clear_tasks

    remove_file @temp_path
    remove_file @temp_cache

    @temp_path  = nil
    @temp_cache = nil

    if(@start_path && Dir.pwd != @start_path)
      puts "[WARNING] >> SproutTestCase changing dir from #{Dir.pwd} back to: #{@start_path} - Did you mean to leave your working directory in a new place?"
      Dir.chdir @start_path
    end
  end

  protected

  ##
  # Create a temporary folder relative to the
  # test case that calls this method.
  # 
  # @return [Dir] Path to the requested temp folder.
  def temp_path
    caller_file = Sprout.file_from_caller caller.first
    @temp_path ||= make_temp_folder File.dirname(caller_file)
  end

  ##
  # Create a temporary folder relative to the
  # provided path.
  #
  # @param from [Dir] Folder within which a 'tmp' folder should be added.
  #
  # @return [Dir] Path to the requested temp folder.
  def make_temp_folder from
    dir = File.join(fixtures(from), 'tmp')
    FileUtils.mkdir_p dir
    dir
  end

  ##
  # Invoke a Rake task by name.
  #
  # @return [Rake::Task] The task that was invoked.
  def run_task(name)
    t = Rake.application[name]
    t.invoke
    return t
  end
  
  ##
  # Retrieve a registered Rake task by name.
  #
  # @return [Rake::Task] The task that was found.
  def get_task(name)
    return Rake.application[name]
  end

  ##
  # Clear all registered Rake tasks.
  def clear_tasks
    CLEAN.delete_if {|a| true }
    Rake::Task.clear
    Rake.application.clear
  end

  ##
  # Create an empty file at +path+
  #
  # @param [File] The path to the file that should be created.
  # @return [File] The path to the file.
  def create_file path
    dir = File.dirname path
    FileUtils.mkdir_p dir
    FileUtils.touch path
  end

  ##
  # Remove a file if it exists. If no file exists,
  # do nothing.
  #
  # @param path [File] Path to the file that should be removed.
  def remove_file(path=nil)
    if(path && File.exists?(path))
      FileUtils.rm_rf(path)
    end
  end

  ##
  # Assert that a file exists at +path+ and display +message+ 
  # if it does not.
  #
  # @param path [File] Path to the file that should exist.
  # @param message [String] The message that should be displayed if the expected file does not exist.
  # @yield [String] The contents of the file.
  #
  # This method yields the file contents so that you can write 
  # readable tests like:
  #
  #   assert_file File.join(fixtures, 'my_file') do |f|
  #     assert_matches /Johnny/, f
  #   end
  #
  def assert_file(path, message=nil)
    message ||= "Expected file not found at #{path}"
    assert(File.exists?(path), message)
    yield File.read(path) if block_given?
  end

  ##
  # Assert that a directory exists at +path+ and display +message+
  # if it does not.
  #
  # @param path [Dir] Path to the directory that should exist.
  # @param message [String] The message that should be displayed if the expected directory does not exist.
  #
  #    assert_directory File.join(fixtures, 'SomeDir')
  #
  def assert_directory(path, message=nil)
    message ||= "Expected directory not found at #{path}"
    assert(File.directory?(path), message)
  end

  ##
  # Assert that a file exists at +path+ and is not empty. Display
  # +message+ if the file does not exist or if it is empty.
  # @param path [File] Path to the file that should exist.
  # @param message [String] The message that should be displayed if 
  #   the expected file does not exist or is empty.
  #
  #   assert_not_empty File.join(fixtures, 'SomeFile')
  #
  def assert_not_empty(path, message=nil)
    assert_file path, message
    files = FileList["#{path}/*"]
    message ||= " - Expected #{path} to not be empty, but it was"
    assert files.size > 0, message
  end
  
  ##
  # Assert that an expression matches the provided string.
  #
  # This helper mainly makes tests more readable and provides
  # simpler failure messages without extra work.
  #
  #   assert_matches /Fred/, 'Bill, Fred, Bob'
  #
  def assert_matches(expression, string, message='')
    if(expression.is_a?(String))
      expresion = /#{expression}/
    end
    if(!string.match(expression))
      fail "#{message} - '#{string}' should include '#{expression}'"
    end
  end

  ##
  # Update the Sprout::Executable registry so that subsequent
  # requests for an executable return a fake one instead of
  # the real one.
  #
  # @param exe [Symbol] The executable that will be sent to the load request (e.g. :fdb, :mxmlc, etc.).
  # @param fake_name [String] The path to the fake executable that should be used.
  #
  # Note: Calling this method will set a mocha expectation
  # that the Sprout::Executable.load method will be called during
  # the test method run.
  #
  def insert_fake_executable fake
    # Comment the following and install the flashsdk gem
    # to run test against actual executables instead of fakes:
    path_response = OpenStruct.new(:path => fake)
    Sprout::Executable.expects(:load).returns path_response
  end

  ##
  # Create and/or return sprout/cache directory relative to the
  # fixtures folder nearest the file that calls this method.
  # @return [Dir] The path to the cache directory.
  def temp_cache
    dir = File.dirname(Sprout.file_from_caller(caller.first))
    @temp_cache ||= File.join(fixtures(dir), 'sprout', 'cache')
  end

  ##
  # Execute a block as each available Sprout::System, any code
  # within this block that calls Sprout.current_user will
  # receive the currently active Sprout::System.
  #
  #    as_each_system do
  #      puts ">> Sprout.home: #{Sprout.home}"
  #    end
  #
  # This method is primarily used to ensure that we create 
  # system-appropriate paths and processes.
  #
  # NOTE: This process automatically calls Mocha::Mockery.instance.teardown
  # after the yield. This means that any mocks that have been created will
  # no longer be available after the provided block is complete.
  # 
  # @return [Sprout::System::BaseSystem] The concrete class that was created.
  # @yield [Sprout::System::BaseSystem] The concrete subclass of BaseSystem
  #
  def as_each_system
    [
     Sprout::System::VistaSystem.new,
     Sprout::System::WinNixSystem.new,
     Sprout::System::WinSystem.new,
     Sprout::System::JavaSystem.new,
     Sprout::System::OSXSystem.new,
     Sprout::System::UnixSystem.new
    ].each do |sys|
      expectation = Sprout::System.stubs(:create).returns sys
      yield sys if block_given?
      # Ugh - This is way too greedy... We're killing all mocks in here
      # Doing it anyway b/c we need to get Windows support in place...
      # TODO: Implement this feature without clobbering all stubs/mocks
      Mocha::Mockery.instance.teardown
      sys
    end
  end

  ##
  # Execute a block as a UnixSystem.
  #
  #   as_a_unix_system do
  #      puts ">> Sprout.home: #{Sprout.home}"
  #   end
  #
  # @return [Sprout::System::UnixSystem] The Sprout::System that was created.
  # @yield [Sprout::System::UnixSystem] The current Sprout::System.
  def as_a_unix_system
    sys = Sprout::System::UnixSystem.new
    expectation = Sprout::System.stubs(:create).returns sys
    yield sys if block_given?
    # Ugh - This is way too greedy... We're killing all mocks in here
    # Doing it anyway b/c we need to get Windows support in place...
    # TODO: Implement this feature without clobbering all stubs/mocks
    #Mocha::Mockery.instance.teardown
    sys
  end

  ##
  # Execute a block as a OSXSystem.
  #
  #   as_a_mac_system do
  #      puts ">> Sprout.home: #{Sprout.home}"
  #   end
  #
  # @return [Sprout::System::OSXSystem] The Sprout::System that was created.
  # @yield [Sprout::System::OSXSystem] The current Sprout::System.
  def as_a_mac_system
    sys = Sprout::System::OSXSystem.new
    Sprout::System.stubs(:create).returns sys
    yield sys if block_given?
    # Ugh - This is way too greedy... We're killing all mocks in here
    # Doing it anyway b/c we need to get Windows support in place...
    # TODO: Implement this feature without clobbering all stubs/mocks
    #Mocha::Mockery.instance.teardown
    sys
  end
  
  ##
  # Execute a block as a WinSystem.
  #
  #   as_a_windows_system do
  #      puts ">> Sprout.home: #{Sprout.home}"
  #   end
  #
  # @return [Sprout::System::WinSystem] The Sprout::System that was created.
  # @yield [Sprout::System::WinSystem] The current Sprout::System.
  def as_a_windows_system
    sys = Sprout::System::WinSystem.new
    Sprout::System.stubs(:create).returns sys
    yield sys if block_given?
    # Ugh - This is way too greedy... We're killing all mocks in here
    # Doing it anyway b/c we need to get Windows support in place...
    # TODO: Implement this feature without clobbering all stubs/mocks
    #Mocha::Mockery.instance.teardown
    sys
  end

  ##
  # Execute a block as a WinNixSystem.
  #
  #   as_a_win_nix_system do
  #      puts ">> Sprout.home: #{Sprout.home}"
  #   end
  #
  # @return [Sprout::System::WinNixSystem] The Sprout::System that was created.
  # @yield [Sprout::System::WinNixSystem] The current Sprout::System.
  def as_a_win_nix_system
    sys = Sprout::System::WinNixSystem.new
    Sprout::System.stubs(:create).returns sys
    yield sys if block_given?
    # Ugh - This is way too greedy... We're killing all mocks in here
    # Doing it anyway b/c we need to get Windows support in place...
    # TODO: Implement this feature without clobbering all stubs/mocks
    #Mocha::Mockery.instance.teardown
    sys
  end

  
  private

  ##
  # Find the nearest fixtures folder to the provided
  # path by checking each parent directory.
  def find_fixtures path
    # Return nil if path is nil or is not a file:
    find_fixtures_error(path) if(find_reached_root?(path))
    # Get the parent directory if path is a file:
    path = File.dirname(path) if !File.directory? path
    if(should_create_fixtures_for?(path))
      FileUtils.makedirs File.join(path, FIXTURES_NAME)
    end
    # Check for a folder at "#{path}/fixtures":
    fixture_path = File.join(path, FIXTURES_NAME)
    # Return the fixtures folder if found:
    return fixture_path if File.directory? fixture_path
    # Move up one directory and try again:
    return find_fixtures File.dirname(path) unless File.dirname(path) == path
  end

  def should_create_fixtures_for? path
    basename = File.basename path
    return basename == 'test' || basename == 'tests'
  end

  def find_fixtures_error path
    raise Sprout::Errors::UsageError.new "Request to find a fixtures folder failed at: #{path}"
  end

  def find_reached_root? path
    return (path.nil? || !File.exists?(path) || File.dirname(path) == path)
  end

end

  # TODO: Consider adding these:
  # Some generator-related assertions:
  #   assert_generated_file(name, &block) # block passed the file contents
  #   assert_directory_exists(name)
  #   assert_generated_class(name, &block)
  #   assert_generated_module(name, &block)
  #   assert_generated_test_for(name, &block)
  # The assert_generated_(class|module|test_for) &block is passed the body of the class/module within the file
  #   assert_has_method(body, *methods) # check that the body has a list of methods (methods with parentheses not supported yet)
  #
  # Other helper methods are:
  #   app_root_files - put this in teardown to show files generated by the test method (e.g. p app_root_files)
  #   bare_setup - place this in setup method to create the app_root folder for each test
  #   bare_teardown - place this in teardown method to destroy the TMP_ROOT or app_root folder after each test


# Prevent log messages from interrupting the test output:
Sprout::Log.debug = true
#Sprout::ProgressBar.debug = true

