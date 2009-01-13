require File.dirname(__FILE__) + '/test_helper'
require 'sprout/preprocessor'

class PreprocessorTest <  Test::Unit::TestCase
  include SproutTestCase
  include GeneratorTestHelper
  
  def setup
    @instance = Sprout::Preprocessor.new
    @instance.temp_dir = '_preprocessed'
    @start = Dir.pwd
    Dir.chdir("#{fixtures}/preprocessor/simple")
  end
  
  def teardown
    @instance.unexecute
    @instance = nil
    Dir.chdir(@start)
  end
  
  def test_instantiated
    assert(@instance, "Preprocessor should exist")
  end
  
  def test_temp
    path = 'src'
    dir = @instance.temp_dir
    temp_file = "#{dir}/src/SomeFile.txt"
    
    @instance.execute do |p|
      p.paths << path
      p.command = 'cpp -DDEBUG=foo -P - -'      
    end
    
    assert_equal(1, @instance.paths.size)
    assert_file_exists(dir)
#    assert_file_exists(temp_file)
#    assert_file_contains(file, 'foo')
  end
end