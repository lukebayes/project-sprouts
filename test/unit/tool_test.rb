require File.dirname(__FILE__) + '/test_helper'

class ToolTest < Test::Unit::TestCase
  include SproutTestCase

  context "a newly included tool" do

    setup do
      @echo_chamber = File.join fixtures, 'tool', 'echochamber_gem', 'lib', 'echo_chamber'
    end

    should "require the sproutspec" do
      assert_equal 0, Sprout.executables.size
      path = Sprout.load_executable :echos, @echo_chamber
      assert_matches /fixtures\/.*echochamber.sh/, path
    end
  end
end

