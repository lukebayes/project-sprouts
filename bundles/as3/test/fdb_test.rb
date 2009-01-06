require File.dirname(__FILE__) + '/test_helper'

class FDBTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start                  = Dir.pwd
    fixture                 = File.join(fixtures, 'fdb')
    @swf                    = 'SomeProject-debug.swf'
    @runner_swf             = 'XMLRunner.swf'
    @exception_swf          = 'Exception.swf'
    Dir.chdir fixture
  end
  
  def teardown
    remove_file 'AsUnitResults.xml'
    Dir.chdir @start
    clear_tasks
  end
  
  def create_buffer(input=nil)
    process = MockProcess.new
    output = MockProcess.new
    buffer = FDBBufferStub.new(process, output)

    process.print input unless input.nil?
    sleep(0.2)

    return [process, output, buffer]
  end

  def test_instantiated
    debugger = fdb :debug
    assert debugger.is_a?(Sprout::FDBTask)
  end
  
  def test_simple_buffer
    str = "Adobe"
    process, output, buffer = create_buffer(str)
    
    sleep(1.8)
    
    assert_equal(str, output)
    
  end
  
  def test_fdb_buffer
    str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
    str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
    str << "(fdb) "
    
    process, output, buffer = create_buffer str
    assert_equal(str, output)
  end
  
  def test_fdb_buffer_wait_for_prompt
    str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
    str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
    str << "(fdb) "
  
    process, output, buffer = create_buffer
    process.print str
  
    timeout 1 do
      buffer.wait_for_prompt
    end
  end
  
  def test_fdb_confirmation_prompt
    str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
    str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
    str << "The program is running.  Exit anyway? (y or n) "
  
    process, output, buffer = create_buffer
    process.print str
  
    timeout 1 do
      buffer.wait_for_prompt
    end
    
  end
  
=begin

  # These tests only work well when executed
  # individually. Otherwise they junk up output
  # and don't seem to clean up the Flash Player
  # fast enough to be executed in a suite:
  
  def test_close_on_error
    debugger = fdb :debugger do |t|
      t.kill_on_fault = true
      t.file = @exception_swf
      t.run
      t.continue
    end
    
    debugger.execute
  end
  
  def test_close_after_unit_tests
    debugger = fdb :debugger do |t|
      t.kill_on_fault = true
      t.file = @runner_swf
      t.run
      t.continue
    end
    
    debugger.execute
  end

  def test_launch_player
    debugger = fdb :debug do |t|
      t.file = @swf
      t.run
      t.break = "SomeProject.as#4"
#      t.continue
#      t.sleep_until('SomeProject instantiated!')
#      t.continue
#      t.quit
#      t.pwd
#      t.continue
#      t.info
#      t.continue
#      t.quit
#      t.info_variables
    end
    
    debugger.invoke
  end
=end

end

class FDBBufferStub < Sprout::FDBBuffer

  def initialize(input, output, user_input=nil)
    @mock_input = input
    super
  end
  
  # Use provided mock input instead of external ProcessRunner
  def create_input(exe)
    @mock_input
  end
  
end

class MockProcess < String
  
  def readpartial(count)
    if(size == 0)
      sleep(0.10)
      return readpartial(count)
    end
    
    return self.slice!(0).chr
  end
  
  def print(msg)
    self << msg
  end
  
  def flush
  end
end

