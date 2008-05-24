require File.dirname(__FILE__) + '/test_helper'

class COMPCTest <  Test::Unit::TestCase
  include SproutTestCase

  # see tasks/compc_task.rb for todos
  # This feature is only partially implemented at this time
  # Once the implementation is complete, the output of compc
  # should work as input for mxmlc

  def setup
    @start          = Dir.pwd
    fixture         = File.join(fixtures, 'compc')
    Dir.chdir(fixture)
 
    @mxmlc_output   = 'bin/MXMLC.swf'
    @compc_input    = 'SomeProject'
    @compc_output   = 'bin/COMPC.swc'
    @src            = 'src'
    @test           = 'test'

    remove_file(@compc_output)
  end
  
  def teardown
    super
    remove_file(@compc_output)
    Dir.chdir(@start)
  end
  
  def test_basic_compilation
    
    compc @compc_output do |t|
      t.input = @compc_input
      t.source_path << 'src'
      t.source_path << 'test'
    end

    run_task @compc_output
    
    assert_file(@compc_output)
  end

end
