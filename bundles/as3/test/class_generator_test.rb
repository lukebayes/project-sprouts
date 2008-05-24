require File.dirname(__FILE__) + '/test_helper'

class ClassGeneratorTest < Test::Unit::TestCase
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
    super('as3', 'class', [name], @local_generators)
  end
  
  def test_create_with_test_case
    run_generator('class_source/classtest.utils.FooUtilTest')
    
    clazz = File.join(@fixture, 'class_source', 'classtest', 'utils', 'FooUtil.as')
    test = File.join(@fixture, 'class_test', 'classtest', 'utils', 'FooUtilTest.as')
    suite = File.join(@fixture, 'class_test', 'AllTests.as')
    
    assert(!File.exists?(clazz), "Class should not have been created")
    assert_file_contains(test, 'public class FooUtilTest extends TestCase')

    assert_file_contains(suite, 'import classtest.utils.FooUtilTest')
    assert_file_contains(suite, 'addTest(new classtest.utils.FooUtilTest())')

  end

  # Ensure that a variety of class name inputs
  # result in a valid and expected class being
  # created.
  def test_generate_with_varied_class_entries
    forms = ['classtest.utils.MathUtil', 
             'classtest.utils.MathUtil.as', 
             'classtest/utils/MathUtil', 
             'classtest/utils/MathUtil.as'
             ]
    forms.each do |form|
      run_generator(form)
      assert_generated_class(form, @src_dir)
      remove_file(@src_dir)
      FileUtils.mkdir_p(@src_dir)
      remove_file(@test_dir)
      FileUtils.mkdir_p(@test_dir)
    end
  end

end
