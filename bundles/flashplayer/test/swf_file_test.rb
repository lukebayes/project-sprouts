require File.dirname(__FILE__) + '/test_helper'

class SWFFileTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start                  = Dir.pwd
    fixture                 = File.join(fixtures, 'flashplayer')
    @swf                    = 'Runner-debug.swf'
    Dir.chdir fixture
  end
  
  def teardown
    Dir.chdir @start
    clear_tasks
  end
  
  def test_instantiated
    Sprout::SWFFile.new @swf do |swf|
      assert swf.debug?
    end
  end

end
