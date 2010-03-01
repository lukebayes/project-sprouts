require File.dirname(__FILE__) + '/test_helper'

class ToolTest < Test::Unit::TestCase

  context "A tool" do

    context "that is requested" do

      setup do
        @exe = fixtures + '/flex3sdk/bin/mxmlc' 
      end

      teardown do
        ENV['SPROUT_FLEX3SDK_TOOL_3_3_1'] = nil
        ENV['SPROUT_FLEX3SDK_TOOL'] = nil
      end

      #should "download the gem if necessary" do
      #  Sprout::Builder.any_instance.stubs(:build).returns nil
      #end

      should "be found by environmental variable and version" do
        ENV['SPROUT_FLEX3SDK_TOOL_3_3_1'] = fixtures + '/tool_test/flex3sdk'
        tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc', '3.3.1')
        assert_equal @exe, tool.installed_path
      end

      should "throw error if environmental variable is set, but files not found" do
        ENV['SPROUT_FLEX3SDK_TOOL_3_3_1'] = fixtures + '/path_that_does_not_exist'
        assert_raises Sprout::SproutError do
          tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc', '3.3.1')
        end
      end

      #should "be found by environmental variable name only" do
      #  ENV['SPROUT_FLEX3SDK_TOOL'] = fixtures + '/tool_test/sdk'
      #  tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc')
      #end
      
    end
  end

  private

  def fixtures
    File.expand_path(File.dirname(__FILE__) + '/fixtures')
  end
end

