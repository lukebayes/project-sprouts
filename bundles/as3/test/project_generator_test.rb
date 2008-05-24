require File.dirname(__FILE__) + '/test_helper'

class ProjectGeneratorTest < Test::Unit::TestCase
  include GeneratorTestHelper
  
  def setup
    super
    @start = Dir.pwd
    @project_name = 'SomeProject'
    @fixture = File.expand_path(File.join(fixtures, 'project'))
    Sprout::Sprout.project_name = @project_name
    Sprout::Sprout.project_path = @fixture
    Dir.chdir(@fixture)
  end
  
  def teardown
    remove_file(@project_name)
    Dir.chdir(@start)
    super
  end
  
  def run_generator(name)
    super('as3', 'project', [name], @local_generators)
  end
  
  def test_generate_project
    run_generator(@project_name)
    assert_file(File.join(@fixture, @project_name))
    assert_file(File.join(@fixture, @project_name, 'assets/skins/SomeProject/ProjectSprouts.png'))
    assert_executable File.join(@fixture, @project_name, 'script', 'generate')
  end
  
end
