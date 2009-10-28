require File.dirname(__FILE__) + '/test_helper'

class SuiteGeneratorTest < Test::Unit::TestCase
  include GeneratorTestHelper

  def setup
    super
    @start = Dir.pwd
    @fixture = File.expand_path(File.join(fixtures, 'generators'))
    @test_suite = File.join(@fixture, 'test', 'AllTests.as')
    Dir.chdir(@fixture)
    Sprout::Sprout.project_path = @fixture
  end
  
  def teardown
    remove_file(@test_suite)
    Dir.chdir(@start)
    super
  end

  def test_generator
    run_generator('as3', 'suite', [''], @local_generators)

    assert_file @test_suite
    content = File.open(@test_suite, 'r').read
    
    assert(content.index('import display.OtherComponentTest;'), 'Unexpected import for OtherComponentTest')
    assert(content.index('import display.SomeComponentTest;'), 'Unexpected import for SomeComponentTest')
    assert(content.index('import utils.MathUtilTest;'), 'Unexpected import for MathUtilTest')
    assert(content.index('addTest(new display.OtherComponentTest());'), 'Unexpected instatiation for OtherComponentTest')
    assert(content.index('addTest(new display.YetAnotherComponentTest());'), 'Unexpected instatiation for YetAnotherComponentTest')
    assert(content.index('addTest(new net.http.YamlTest());'), 'Unexpected instatiation for YamlTest')
  end
end
