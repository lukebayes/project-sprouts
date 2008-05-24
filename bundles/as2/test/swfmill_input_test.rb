require File.dirname(__FILE__) + '/test_helper'

class SWFMillInputTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    fixture = File.join(fixtures, 'swfmill')
    @input = File.join(fixture, 'skin')
    @output = File.join(fixture, 'SWFMill.xml')
    @template = File.join(fixture, Sprout::SWFMillInputTask::DEFAULT_TEMPLATE)
  end
  
  def teardown
    super
    remove_file @template
    remove_file @output
  end

  def test_simple
    swfmill_input @output do |t|
      t.input = @input
    end
    
    run_task @output
    assert_file(@output)
    assert_file(@template)
  end
  
end
