require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class FCSHServiceTest <  Test::Unit::TestCase
  
  attr_reader :service

  def setup
    @path = File.dirname(__FILE__) + '/fixtures/mxmlc'
    @start = Dir.pwd
    Dir.chdir @path

    @fcsh = Sprout::FCSHService.new
    @task = "mxmlc -source-path=src/ -output=bin/SomeProject.swf src/SomeProject.as"
    super
  end

  def teardown
    super
    remove_file('bin/SomeProject.swf')
    Dir.chdir @start
  end
  
  def test_open
    @fcsh.open(Dir.pwd)
    @fcsh.compile(@task)
    
    puts "COMPILE FINISHED!"
  end
  
end

=begin
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

