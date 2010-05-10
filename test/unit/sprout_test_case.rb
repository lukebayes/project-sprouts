
require 'rubygems/installer'
require 'fixtures/mock_gem_ui'
require 'test/unit/fake_tool'

# Had to make this a module instead of a base class
# because the ruby test suite kept complaining that 
# the abstract test case didn't have any test mehods
# or assertions
module SproutTestCase # :nodoc:[all]

  # Gives us the ability to hide RubyGem output from
  # our test results...
  include Gem::DefaultUserInteraction

  def fixtures
    @fixtures ||= File.expand_path(File.join(File.dirname(__FILE__), '/../fixtures'))
  end

  def setup
    super
    @mock_gem_ui = MockGemUi.new
    @start_path = Dir.pwd
    temp_path # Call before someone can Dir.chdir...
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
    @temp_path ||= make_temp_folder
  end

  def make_temp_folder
    path = File.expand_path( File.dirname(__FILE__) + '/../tmp' )
    if(!File.exists?(path))
      FileUtils.mkdir_p path
    end
    path
  end

  def as_a_unix_user
    Sprout::User.stubs(:create).returns Sprout::User::UnixUser.new
    yield if block_given?
  end

  def as_a_mac_user
    Sprout::User.stubs(:create).returns Sprout::User::OSXUser.new
    yield if block_given?
  end
  
  
  def run_task(name)
    t = Rake.application[name]
    t.invoke
    return t
  end
  
  def get_task(name)
    return Rake.application[name]
  end

  def clear_tasks
    #Sprout::ToolTask::clear_preprocessed_tasks
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

  def temp_cache
    @temp_cache ||= File.join(fixtures, 'sprout', 'cache')
  end
  
end

module Sprout
  def self.clear_executables!
    executables.delete_if { |a,b| true }
  end
end

