require File.dirname(__FILE__) + '/test_helper'

class SproutTest < Test::Unit::TestCase

  context "Ensure each error can be instantiated" do
    include Sprout::Errors

    [
      ArchiveUnpackerError,
      DestinationExistsError,
      ExecutionError, 
      ProcessRunnerError,
      SproutError, 
      ToolError,
      UnknownArchiveType,
      UsageError 
    ].each do |error|

      should "be able to instiate a #{error.to_s}" do
        error.new
      end
    end
  end

  context "requesting an executable" do

    should "fail if the tool has not yet registered" do
      assert_raises Sprout::Errors::ToolError do
        exe = Sprout.get_executable :mxmlc, 'flex3sdk'
      end
    end

    should "succeed if the tool has been registered" do
      target = 'test/fixtures/process_runner/chmod_script.sh'
      Sprout.add_executable :mxmlc, 'flex3sdk', target
      assert_equal target, Sprout.get_executable(:mxmlc, 'flex3sdk')
    end
  end

end

