require File.dirname(__FILE__) + '/test_helper'

class ComponentGeneratorTest < Test::Unit::TestCase
  include GeneratorTestHelper
  
  def setup
    super
    @start = Dir.pwd
    @fixture = File.expand_path(File.join(fixtures, 'generators'))
    @src_dir = 'class_source'
    @test_dir = 'class_test'
    
    model = Sprout::ProjectModel.instance
    model.src_dir = @src_dir
    model.test_dir = @test_dir

    Dir.chdir(@fixture)
    Sprout::Sprout.project_path = @fixture
  end
  
  def teardown
    remove_file(@src_dir)
    remove_file(@test_dir)
    Dir.chdir(@start)
    Sprout::ProjectModel.destroy
    super
  end
  
  def run_generator(name)
    super('as3', 'component', [name], @local_generators)
  end
  
  def test_create_with_test_case
    run_generator('utils.FooUtil')
    
    clazz = File.join(@fixture, 'class_source', 'utils', 'FooUtil.mxml')
    test = File.join(@fixture, 'class_test', 'utils', 'FooUtilTest.as')
    suite = File.join(@fixture, 'class_test', 'AllTests.as')
    
    assert_file_contains(clazz, '<mx:Canvas xmlns:mx="http://www.adobe.com/2006/mxml" width="100%" height="100%">')

    assert_file_contains(suite, 'import utils.FooUtilTest')
    assert_file_contains(suite, 'addTest(new utils.FooUtilTest())')
  end

end
