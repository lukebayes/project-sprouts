require File.dirname(__FILE__) + '/test_helper'

class FDBTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start                  = Dir.pwd
    fixture                 = File.join(fixtures, 'fdb-exception')
    @swf                    = 'SomeProject-debug.swf'
    Dir.chdir fixture
  end
  
  def teardown
    Dir.chdir @start
    clear_tasks
  end
  
  def create_buffer(str=nil)
    process = MockProcess.new
    output = MockProcess.new
    buffer = FDBBufferStub.new(process, output)

    process.print str unless str.nil?
    sleep(0.2)

    return [process, output, buffer]
  end
  # 
  # def test_instantiated
  #   debugger = fdb :debug
  #   assert debugger.is_a?(Sprout::FDBTask)
  # end
  # 
  # def test_simple_buffer
  #   str = "Adobe"
  #   process, output, buffer = create_buffer(str)
  #   assert_equal(str, output)
  # end
  # 
  # def test_fdb_buffer
  #   str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
  #   str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
  #   str << "(fdb) "
  #   
  #   process, output, buffer = create_buffer str
  #   assert_equal(str, output)
  # end
  # 
  # def test_fdb_buffer_wait_for_prompt
  #   str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
  #   str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
  #   str << "(fdb) "
  # 
  #   process, output, buffer = create_buffer
  #   process.print str
  # 
  #   timeout 1 do
  #     buffer.wait_for_prompt
  #   end
  # end
  # 
  # def test_fdb_confirmation_prompt
  #   str = "Adobe fdb (Flash Player Debugger) [build 3.0.0.477]\n"
  #   str << "Copyright (c) 2004-2007 Adobe, Inc. All rights reserved.\n"
  #   str << "The program is running.  Exit anyway? (y or n) "
  # 
  #   process, output, buffer = create_buffer
  #   process.print str
  # 
  #   timeout 1 do
  #     buffer.wait_for_prompt
  #   end
  #   
  # end
  
  def test_close_on_error
    # debugger = fdb :debugger do |t|
    #   t.kill_on_fault = true
    #   t.file = @swf
    #   t.run
    #   t.continue
    # end
    
    debugger = fdb :debugger do |t|
      t.kill_on_fault = true
      t.file = @swf
      t.run
      t.continue
    end
    
    debugger.execute
  end
  
=begin

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

