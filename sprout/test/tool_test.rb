require File.dirname(__FILE__) + '/test_helper'

class ToolTest < Test::Unit::TestCase

  context "A tool" do

    context "that is requested" do

      setup do
        @expected_exe = fixtures + '/tool_test/flex3sdk/bin/mxmlc' 
        @cached_exe = Sprout::Sprout.sprout_cache + '/sprout-flex3sdk-tool-3.3.1/archive/bin/mxmlc'
      end

      teardown do
        ENV['SPROUT_FLEX3SDK_TOOL_3_3_1'] = nil
        ENV['SPROUT_FLEX3SDK_TOOL'] = nil
      end

      should "use the gem cache if no environment variables are found" do
        Sprout::RemoteFileTarget.any_instance.stubs(:resolve)
        Sprout::RemoteFileTarget.any_instance.expects(:resolve)
        tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc', '3.3.1')
        assert_equal @cached_exe, tool
      end

      should "be found by environmental variable and version" do
        ENV['SPROUT_FLEX3SDK_TOOL_3_3_1'] = fixtures + '/tool_test/flex3sdk'
        tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc', '3.3.1')
        assert_equal @expected_exe, tool
      end

      should "be found by environmental variable name only" do
        ENV['SPROUT_FLEX3SDK_TOOL'] = fixtures + '/tool_test/flex3sdk'
        tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc')
        assert_equal @expected_exe, tool
      end
      
      should "throw error if environmental variable is set, but files not found" do
        ENV['SPROUT_FLEX3SDK_TOOL_3_3_1'] = fixtures + '/path_that_does_not_exist'
        assert_raises Sprout::UsageError do
          tool = Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc', '3.3.1')
        end
      end

    end
  end

  private

  def fixtures
    File.expand_path(File.dirname(__FILE__) + '/fixtures')
  end
end

