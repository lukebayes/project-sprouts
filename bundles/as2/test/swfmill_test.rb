require File.dirname(__FILE__) + '/test_helper'

class SWFMillTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    fixture = File.join(fixtures, 'swfmill')

    @input = File.join(fixture, 'skin')
    @output = File.join(fixture, 'Project.swf')
    @input_xml = File.join(fixture, 'ProjectInput.xml')
    @template = File.join(fixture, 'Template.erb')
  end
  
  def teardown
    super
    remove_file(@output)
    remove_file(@input_xml)
    remove_file(@template)
  end

  def test_directory
    swfmill @output do |t|
      t.input = @input
    end

    run_task @output
    assert_file(@output)
    assert_file(@input_xml)
    assert_file(@template)
  end

end
