require File.dirname(__FILE__) + '/test_helper'

class ToolTest < Test::Unit::TestCase
  include SproutTestCase

  context "a newly included tool" do

    setup do
      @echo_chamber = File.join fixtures, 'tool', 'echochamber_gem', 'lib', 'echo_chamber'
    end

    should "require the sproutspec" do
      assert_equal 0, Sprout.executables.size
      require @echo_chamber
      assert_equal 1, Sprout.executables.size
    end
  end
end

