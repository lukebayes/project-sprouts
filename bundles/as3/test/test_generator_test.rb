require File.dirname(__FILE__) + '/test_helper'

class TestGeneratorTest < Test::Unit::TestCase
  include GeneratorTestHelper

  def setup
    super
    @start = Dir.pwd
    @fixture = File.expand_path(File.join(fixtures, 'generators'))
    @string_util = File.join(@fixture, 'test', 'utils', 'StringUtilTest.as')
    @class_name = 'utils.StringUtilTest'
    Dir.chdir(@fixture)
  end
  
  def teardown
    remove_file(File.join('test', 'AllTests.as'))
    remove_file(@string_util)
    Dir.chdir(@start)
    super
  end
  
	def test_generator
    run_generator('as3', 'test', [@class_name], @local_generators)

    assert_file(@string_util)
    content = File.open(@string_util, 'r').read
    assert(content.index('public class StringUtilTest extends TestCase {'), "TestCase header is not correct")
    assert(content.index('public function StringUtilTest(methodName:String=null) {'), "TestCase constructor is not correct")
    assert(content.index('assertTrue("stringUtil is StringUtil", stringUtil is StringUtil);'), "TestCase default test method is not correct")
	end
	
end
