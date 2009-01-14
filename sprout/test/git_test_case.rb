require 'sprout/tasks/git_task'

class GitTestCase < Test::Unit::TestCase
  
  def teardown
    @version_file = nil
    clear_tasks
    teardown_version_file
  end
  
  def setup_version_file
    @version_file = File.join(fixtures, 'version.txt')
    create_version_file(@version_file)
    return Sprout::VersionFile.new(@version_file)
  end
  
  def teardown_version_file
    remove_file @version_file
  end
  
  def remove_file(path)
    if(!path.nil? && File.exists?(path))
      FileUtils.rm(path)
    end
  end
  
  def run_task(name)
    t = Rake.application[name]
    t.invoke
    return t
  end
  
  def clear_tasks
    Rake::Task.clear
    Rake.application.clear
  end

  def create_version_file(file_path)
    File.open(file_path, 'w+') do |file|
      file.puts '2.3.4'
    end
  end

  def fixtures
    return File.dirname(__FILE__) + '/fixtures'
  end
  
  def test_fixtures
    assert_equal(File.dirname(__FILE__) + '/fixtures', fixtures)
  end

end
