require 'rubygems/installer'
require 'fixtures/mock_gem_ui'
require 'unit/fake_executable_task'
require 'pathname'

# Had to make this a module instead of a base class
# because the ruby test suite kept complaining that 
# the abstract test case didn't have any test mehods
# or assertions
module SproutTestCase # :nodoc:[all]
  FIXTURES_NAME = 'fixtures'

  # Gives us the ability to hide RubyGem output from
  # our test results...
  include Gem::DefaultUserInteraction

  def fixtures from=nil
    @fixtures ||= find_fixtures(from || caller.first.split(':').first)
  end

  def setup
    super
    @mock_gem_ui = MockGemUi.new
    @start_path = Dir.pwd
    #temp_path # Call before someone can Dir.chdir...
  end

  def teardown
    super
    clear_tasks
    Sprout.clear_executables!
    #Sprout::ProjectModel.destroy

    remove_file @temp_path
    remove_file @temp_cache

    if(@start_path && Dir.pwd != @start_path)
      Dir.chdir @start_path
    end

  end

  def temp_path
    @temp_path ||= make_temp_folder(caller.first.split(':').first)
  end

  def make_temp_folder from=nil
    path = File.join(fixtures(from), 'tmp')
    if(!File.exists?(path))
      FileUtils.mkdir_p path
    end
    path
  end

=begin
 THESE DON'T WORK! 
 They both introduced interacting, broken tests...

  def as_a_unix_user
    Sprout::System.stubs(:create).returns Sprout::System::UnixUser.new
    yield if block_given?
  end

  def as_a_mac_user
    Sprout::System.stubs(:create).returns Sprout::System::OSXUser.new
    yield if block_given?
  end
=end 
  
  def run_task(name)
    t = Rake.application[name]
    t.invoke
    return t
  end
  
  def get_task(name)
    return Rake.application[name]
  end

  def clear_tasks
    Rake::Task.clear
    Rake.application.clear
  end

  def create_file path
    dir = File.dirname path
    FileUtils.mkdir_p dir
    FileUtils.touch path
  end

  def remove_file(path=nil)
    if(path && File.exists?(path))
      FileUtils.rm_rf(path)
    end
  end

  def assert_file(path, message=nil)
    message ||= "Expected file not found at #{path}"
    assert(File.exists?(path), message)
    yield File.read(path) if block_given?
  end

  def assert_directory(path, message=nil)
    message ||= "Expected directory not found at #{path}"
    assert(File.directory?(path), message)
  end

  def assert_not_empty(path, message=nil)
    assert_file path, message
    files = FileList["#{path}/*"]
    message ||= " - Expected #{path} to not be empty, but it was"
    assert files.size > 0, message
  end
  
  def assert_matches(expression, string, message='')
    if(expression.is_a?(String))
      expresion = /#{expression}/
    end
    if(!string.match(expression))
      fail "#{message} - '#{string}' should include '#{expression}'"
    end
  end

  ##
  # Add the skip method that was introduced in Ruby 1.9.1 Test::Unit
  if(RUBY_VERSION == '1.8.7')
    def skip message=""
      puts
      puts ">> SproutTestCase.skip called from: #{caller[0]} ( #{message} )"
    end
  end

  def temp_cache
    @temp_cache ||= File.join(fixtures(caller.first.split(':').first), 'sprout', 'cache')
  end

  private

  # Find the nearest fixtures folder to the provided
  # path by checking each parent directory.
  def find_fixtures path
    # Return nil if path is nil or is not a file:
    return nil if(path.nil? || !File.exists?(path))
    # Get the parent directory if path is a file:
    path = File.dirname(path) if !File.directory? path
    # Check for a folder at "#{path}/fixtures":
    fixture_path = File.join(path, FIXTURES_NAME)
    # Return the fixtures folder if found:
    return fixture_path if File.directory? fixture_path
    # Move up one directory and try again:
    return find_fixtures File.dirname(path)
  end

end

module Sprout
  def self.clear_executables!
    executables.delete_if { |a,b| true }
  end
end

