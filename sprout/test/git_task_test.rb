require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/git_test_case.rb'

class GitTaskTest < GitTestCase

  def setup
    super
    @task = nil
    @version = setup_version_file
  end
  
  def test_version_file_loaded
    @task = git :task1 do |t|
      t.scm = GitStub.new
      t.version_file = @version_file
    end
    
    assert_equal('2.3.4', @task.version, 'Version file was not loaded properly')
  end
  
  def test_increment_revision
    git :task1 do |t|
      t.scm = GitStub.new
      t.version_file = @version_file
    end
  
    run_task :task1
  end
end

class GitStub
  
  def tags
    []
  end
  
  def add_tag(name)
  end
  
  def pull
  end
  
  def push(remote, branch, tags)
  end
end
