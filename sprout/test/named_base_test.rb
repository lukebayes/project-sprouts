require File.dirname(__FILE__) + '/test_helper'
require 'sprout/generator'

class NamedBaseTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    super
    @src_dir  = 'source'
    @test_dir = 'testdir'
    @lib_dir  = 'libdir'
    
    @fixture = File.join(fixtures, 'named_base')
    
    # Configure the ProjectModel so that named base uses it
    @model = Sprout::ProjectModel.instance
    @model.src_dir = @src_dir
    @model.test_dir = @test_dir
    @model.lib_dir = @lib_dir
  end
  
  def teardown
    Sprout::ProjectModel.destroy
  end
  
  def assert_math_util(base)
    assert_equal('MathUtil', base.class_name)
    assert_equal('classtest.package', base.package_name)
    assert_equal('classtest.package.MathUtil', base.full_class_name)
    assert_equal('classtest/package', base.class_dir)
    assert_equal('source/classtest/package', base.full_class_dir)
    assert_equal('source/classtest/package/MathUtil.as', base.full_class_path)
    
    assert_equal('MathUtilTest', base.test_case_name)
    assert_equal('classtest.package.MathUtilTest', base.full_test_case_name)
    assert_equal('testdir/classtest/package', base.full_test_dir)
    assert_equal('testdir/classtest/package/MathUtilTest.as', base.full_test_case_path)
  end
  
  def test_with_full_class_name
    base = FakeNamedBase.new(["classtest.package.MathUtil"])
    assert_math_util(base)
    assert(!base.user_requested_test)
  end
  
  def test_with_full_test_case_name
    base = FakeNamedBase.new(["classtest.package.MathUtilTest"])
    assert_math_util(base)
    assert(base.user_requested_test)
  end
  
  def test_with_source_path
    base = FakeNamedBase.new(["source/classtest/package/MathUtil"])
    assert_math_util(base)
  end
  
  def test_with_test_path
    base = FakeNamedBase.new(["testdir/classtest/package/MathUtilTest"])
    assert_math_util(base)
  end
  
  def test_with_no_package
    base = FakeNamedBase.new(["MathUtil"])
    assert_equal('MathUtil', base.class_name)
    assert_equal('', base.package_name)
    assert_equal('MathUtil', base.full_class_name)
    assert_equal('', base.class_dir)
    assert_equal('source', base.full_class_dir)
    assert_equal('source/MathUtil.as', base.full_class_path)
    
    assert_equal('MathUtilTest', base.test_case_name)
    assert_equal('MathUtilTest', base.full_test_case_name)
    assert_equal('testdir', base.full_test_dir)
    assert_equal('testdir/MathUtilTest.as', base.full_test_case_path)
  end
  
  def test_project_model
    base = FakeNamedBase.new(["classtest.package.MathUtil"])

    assert_equal(@src_dir, base.src_dir)
    assert_equal(@test_dir, base.test_dir)
    assert_equal(@lib_dir, base.lib_dir)
  end
  
  def test_find_test_cases
    @model.test_dir = @fixture
    expected_test_cases = ['display/OtherComponentTest.as',
                           'display/SomeComponentTest.as',
                           'display/YetAnotherComponentTest.as',
                           'net/http/YamlTest.as',
                           'utils/MathUtilTest.as']
    
    assert(expected_test_cases.size > 0, 'Expect more than zero test cases to be found')
    base = FakeNamedBase.new(['AllTests'])
    base.test_cases.each do |test_case|
      file = test_case.gsub(@fixture + '/', '')
      index = expected_test_cases.index(file)
      if(index)
        # Remove the found test case
        expected_test_cases.slice!(index, 1)
      end
    end

    assert(expected_test_cases.size == 0, "All expected test cases weren't found: #{expected_test_cases.join(', ')}")
    
  end
  
  def test_find_test_classes
    @model.test_dir = @fixture
    expected_test_classes = ['display.OtherComponentTest',
                           'display.SomeComponentTest',
                           'display.YetAnotherComponentTest',
                           'net.http.YamlTest',
                           'utils.MathUtilTest']

    assert(expected_test_classes.size > 0, 'Expect more than zero test cases to be found')
    base = FakeNamedBase.new(['AllTests'])
    
    base.test_case_classes.each do |test_case|
     index = expected_test_classes.index(test_case)
     if(index)
       # Remove the found test case
       expected_test_classes.slice!(index, 1)
     end
    end

    assert(expected_test_classes.size == 0, "All expected test classes weren't found: #{expected_test_classes.join(', ')}")
  end

  def test_as_file_to_class
    base = FakeNamedBase.new(['AllTests'])
    result = base.actionscript_file_to_class_name('display/OtherComponentTest.as')
    assert_equal('display.OtherComponentTest', result)

    result = base.actionscript_file_to_class_name('source/display/OtherComponent.as')
    assert_equal('display.OtherComponent', result)

    result = base.actionscript_file_to_class_name('testdir/display/OtherComponent.as')
    assert_equal('display.OtherComponent', result)
  end
  
end

# Prevent the lookup service from looking for gems and generators in the test context
class FakeNamedBase < Sprout::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    @model = Sprout::ProjectModel.instance
    @args = runtime_args.dup
    assign_names! @args.shift
  end
end
