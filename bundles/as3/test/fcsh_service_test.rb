require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'
require File.dirname(__FILE__) + '/../../../sprout/test/generator_test_helper'

class FCSHServiceTest <  Test::Unit::TestCase
  
  attr_reader :service
  
  include GeneratorTestHelper

  def setup
    @path = File.dirname(__FILE__) + '/fixtures/mxmlc'
    @start = Dir.pwd
    Dir.chdir @path

    fake_stdin, fake_stdout = IO.pipe
    # Uncomment to see output:
    # @fcsh = Sprout::FCSHService.new
    @fcsh = Sprout::FCSHService.new(fake_stdout)
    @task = "mxmlc -source-path=src/ -output=bin/SomeProject.swf src/SomeProject.as"
    @failing_task = "mxmlc -source-path=src/ -output=bin/SomeProjectFailure.swf src/SomeProjectFailure.as"
    @warning_task = "mxmlc -source-path=src/ -output=bin/SomeProjectWarning.swf src/SomeProjectWarning.as"
    super
  end

  def teardown
    super
    remove_file('bin/SomeProject.swf')
    remove_file('bin/SomeProjectWarning.swf')
    Dir.chdir @start
  end

  def test_compile_twice
    result = @fcsh.execute(@task)
    assert_file_exists('bin/SomeProject.swf')
    assert(result =~ /Assigned 1/, "First run should assign the compilation number:\n#{result}")
  
    FileUtils.touch('src/SomeProject.as')
  
    result = @fcsh.execute(@task)
    assert_file_exists('bin/SomeProject.swf')
    assert(result =~ /has been updated/, "Second run should include some mention of an updated file in:\n#{result}")
  end

  def test_compilation_error
    result = @fcsh.execute(@failing_task)
    assert(result =~ /Error/, "Compilation with errors should return and describe the error(s):\n#{result}")
  end
  
  def test_compilation_warning
    result = @fcsh.execute(@warning_task)
    assert_file_exists('bin/SomeProjectWarning.swf')

    match_data = result =~ /Warning\:/
    assert_equal(8, match_data.size, result)
    assert(match_data, "Compilation with Warnings should return and describe the warnings(s):\n#{result}")
  end

end
