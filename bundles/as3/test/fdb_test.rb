require File.dirname(__FILE__) + '/test_helper'

class FDBTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start                  = Dir.pwd
    fixture                 = File.join(fixtures, 'fdb')
    @swf                    = 'SomeProject-debug.swf'
    Dir.chdir fixture
  end
  
  def teardown
    Dir.chdir @start
    clear_tasks
  end

  def test_instantiated
    debugger = fdb :debug
    assert debugger.is_a?(Sprout::FDBTask)
  end
  
  def test_simple_buffer
    process = MockProcess.new
    output = MockProcess.new
    buffer = Sprout::FDBBuffer.new(process, output)
    process.print "Adobe"
    sleep(0.2)
    assert_equal("Adobe", output)
  end

  def test_fdb_buffer
    process = MockProcess.new
    output = MockProcess.new
    buffer = Sprout::FDBBuffer.new(process, output)
    
    str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
    str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
    str << "(fdb) "

    process.print str
    
    sleep(0.2)
    assert_equal(str, output)
  end
  
  def test_fdb_buffer_wait_for_prompt
    process = MockProcess.new
    output = MockProcess.new
    buffer = Sprout::FDBBuffer.new(process, output)
    
    str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
    str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
    str << "(fdb) "

    process.print str
    timeout 60 do
      buffer.wait_for_prompt
    end
  end

=begin
  def test_launch_player
    debugger = fdb :debug do |t|
      t.file = @swf
      t.run
      t.continue
      t.pwd
#      t.info_sources
#      t.break = "SomeProject.as#1"
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

class MockProcess < String
  
  def readpartial(count)
    if(size == 0)
      sleep(0.01)
      return readpartial count
    end
    
    return self.slice!(0).chr
  end
  
  def print(msg)
    self << msg
  end
  
  def flush
  end
end

