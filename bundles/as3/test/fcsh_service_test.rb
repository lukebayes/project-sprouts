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
    @fcsh = Sprout::FCSHService.new
    # @fcsh = Sprout::FCSHService.new(fake_stdout)
    @task = "mxmlc -source-path=src/ -output=bin/SomeProject.swf src/SomeProject.as"
    super
  end

  def teardown
    super
    remove_file('bin/SomeProject.swf')
    Dir.chdir @start
  end
  
=begin
  def test_compile_once
    result = @fcsh.execute(@task)
  
    assert_file_exists('bin/SomeProject.swf')
    assert(result =~ /Assigned 1/, "First run should assign the compilation number:\n#{result}")
  end

  def test_compile_twice
    @fcsh.execute(@task)
    assert_file_exists('bin/SomeProject.swf')
  
    FileUtils.touch('src/SomeProject.as')
    result = @fcsh.execute(@task)
    assert_file_exists('bin/SomeProject.swf')
    assert(result =~ /has been updated/, "Second run should include some mention of an updated file in:\n#{result}")
  end

  def test_compilation_warning
  end
=end

  def test_compilation_error
    result = @fcsh.execute(@task)
    puts "FINISH WITH: #{result}"
    # assert(result =~ /Error/, "Compilation with errors should return and describe the error(s):\n#{result}")
  end
  
end

=begin

Did exploration on Client/Service interactions...

module Sprout
  class FCSHClient
    
    def initialize
      @processes = []
    end
    
    def open(path)
      puts "open with: #{path}"
      pid, port = pid_and_port_for(path)
      puts "pid: #{pid}, port: #{port}"
    end
    
    # PID File with lines that look like:
    # [pid]\t[port]\t[path]\n
    # Example:
    # 2324\t8091\t/Users/lbayes/Projects/Foo\n
    def get_pids
      path = Sprout.sprout_cache + '/temp/fcsh.pids'
      pids = []
      if(!File.exists?(path))
        FileUtils.mkdir_p([File.dirname(path)])
        FileUtils.touch([path])
      end

      File.open(path, 'r+') do |file|
        pids = file.readlines
      end
      
      return pids
    end
    
    def write_pid
    end
    
    def pid_and_port_for(path)
      parts = []
      get_pids.each do |pid|
        parts = pid.split("\t")
        if(parts[2] == path)
          return parts[0], parts[1]
        end
      end
      return create_process(path)
    end
    
    def create_process(path)
      exe = Sprout.get_executable('sprout-flex3sdk-tool', 'bin/fcsh')
      process = User.execute_silent(exe)
      @processes = << process
      return process.pid, 5678
    end
  end
end
=end

