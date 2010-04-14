
# Had to make this a module instead of a base class
# because the ruby test suite kept complaining that 
# the abstract test case didn't have any test mehods
# or assertions
module SproutTestCase # :nodoc:[all]

  def fixtures
    @fixtures ||= File.expand_path(File.join(File.dirname(__FILE__), '/../fixtures'))
  end

  def setup
    #Sprout::User.user = nil
  end

  def teardown
    clear_tasks
    #Sprout::ProjectModel.destroy
    if(@temp_path && File.exists?(@temp_path))
      FileUtils.rm_rf(@temp_path)
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

  def remove_file(path=nil)
    if(path && File.exists?(path))
      FileUtils.rm_rf(path)
    end
  end

  def assert_file(path, message=nil)
    message ||= "Expected file not found at #{path}"
    assert(File.exists?(path), message)
  end
  
  def assert_matches(expression, string)
    if(expression.is_a?(String))
      expresion = /#{expression}/
    end
    if(!string.match(expression))
      fail "'#{string}' should include '#{expression}'"
    end
  end
  
end
