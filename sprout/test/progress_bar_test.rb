require File.dirname(__FILE__) + '/test_helper'

class ProgressBarTest < Test::Unit::TestCase

  def setup
    @output = MockOutput.new
    @total = 100
    @amount = 0
    @progress_bar = ProgressBarImpl.new('test bar', @total, @output)
  end
  
  def teardown
    @output = nil
    @total = nil
    @amount = nil
    @progress_bar = nil
  end

  def test_get_width
    assert_equal(80, @progress_bar.get_width, "width: #{@progress_bar.get_width}")
    assert(@progress_bar)
    assert(@output.size > 0)
    
  end
end

class MockOutput
  alias old_print print
  
  def initialize
    @output = ''
  end

  def print(msg)
    @output << msg
  end
  
  def size
    return @output.size
  end
end