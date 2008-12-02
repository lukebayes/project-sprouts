require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class FCSHServiceTest <  Test::Unit::TestCase
  
  attr_reader :service

  def setup
    @service = Sprout::FCSHService.new
    super
  end

  def teardown
    super
  end
  
  def test_open
    assert service.open
  end
  
end
