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
    main_file = File.join(@fixture, @project_name, 'src', @project_name + '.mxml')
    main_runner = File.join(@fixture, @project_name, 'src', @project_name + 'Runner.mxml')

    assert_file(File.join(@fixture, @project_name))
    assert_file(main_file)
    assert_file(main_runner)
    assert_file(File.join(@fixture, @project_name, 'assets/skins/SomeProject/ProjectSprouts.png'))
     
    assert_file_contains(main_runner, "<FlexRunner")
    assert_file_contains(main_file, "xmlns:mx=\"http://www.adobe.com/2006/mxml\"")
    assert_executable File.join(@fixture, @project_name, 'script', 'generate')
    
    # Step into the newly created project and exercise it
    Dir.chdir(@project_name)
    begin
      system "rake clean bin/SomeProject.swf"
      system "ruby script/generate utils.MathUtil"
      system "rake clean bin/SomeProjectRunner.swf"
    ensure
      Dir.chdir('../')
    end
  end
  
end
