require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'
require File.dirname(__FILE__) + '/../../../sprout/test/generator_test_helper'

class FCSHSocketTest <  Test::Unit::TestCase
  
  attr_reader :service
  
  include GeneratorTestHelper

  def setup
    @path = File.dirname(__FILE__) + '/fixtures/mxmlc'
    @start = Dir.pwd
    Dir.chdir @path

    @fake_stdin, @fake_stdout = IO.pipe
    # Uncomment to see output in terminal:
    # @fake_stdout = $stdout

    @task = "mxmlc -source-path=src/ -output=bin/SomeProject.swf src/SomeProject.as"
    super
  end

  def teardown
    super
    remove_file('bin/SomeProject.swf')
    Dir.chdir @start
  end

  def test_compile_over_socket

    t = Thread.new {
      Sprout::FCSHSocket.server(12321, @fake_stdout)
    }

    # Compile the first time:
    response = Sprout::FCSHSocket.execute(@task)
    assert_file_exists('bin/SomeProject.swf')
    assert(response =~ /Assigned 1/, "First run should assign the compilation number:\n#{response}")

    FileUtils.touch('src/SomeProject.as')

    # Compile the second time:
    response = Sprout::FCSHSocket.execute(@task)
    assert_file_exists('bin/SomeProject.swf')
    assert(response =~ /has been updated/, "Second run should include some mention of an updated file in:\n#{response}")
  end
end
