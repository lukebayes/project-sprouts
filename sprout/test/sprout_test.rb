require File.dirname(__FILE__) + '/test_helper'

class SproutTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
#    exec('sudo gem uninstall sprout-mtasc-tool')
    @project_name = 'SomeProject'
    @start = Dir.pwd
    @fixture = File.join(fixtures, 'project')
    Dir.chdir(@fixture)
    @project = File.join(@fixture, @project_name)
  end
  
  def teardown
    super
    remove_file @project
    Dir.chdir(@start)
  end

  def test_default_project_path
    path = Sprout::Sprout.project_path
    expanded_result = File.expand_path(path)
    expanded_expected = File.expand_path(Dir.pwd)
    assert(path)
    assert_equal(expanded_expected, expanded_result)
  end
  
  def test_get_executable
    exe = Sprout::Sprout.get_executable('sprout-mtasc-tool')
    assert_file(exe)
  end
  
  def test_get_rakefile
    rakefile = Sprout::Sprout.project_rakefile
    expanded_result = File.expand_path(rakefile)
    expanded_expected = File.expand_path(File.join(Dir.pwd, "rakefile.rb"))
    assert_equal(expanded_expected, expanded_result)
  end
  
  def test_load_rakefile
    rakefile = Sprout::Sprout.project_rakefile
    load rakefile
    assert_equal("foo", Sprout::ProjectModel.instance.test_dir)
  end
  
  def test_project_name
    Sprout::Sprout.project_name = 'SomeProject'
    assert_equal 'SomeProject', Sprout::Sprout.project_name
  end
  
#  def test_generate
#    sprout('as3')
#    Sprout::Sprout.generate(:project, [@project_name])
#  end
  
#  def test_project_name
#    sprout('as3')
#  end
  
end

