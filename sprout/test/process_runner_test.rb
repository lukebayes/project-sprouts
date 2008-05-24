require File.dirname(__FILE__) + '/test_helper'

class ProcessRunnerTest < Test::Unit::TestCase

  def test_unknown_process
    
    assert_raise Sprout::ProcessRunnerError do 
      runner = Sprout::ProcessRunner.new('SomeUnknownExecutableThatCantBeInYourPath --some-arg true --other-arg false')
    end
  end

end