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
      assert_raises Sprout::Errors::MissingExecutableError do
        exe = Sprout.get_executable :mxmlc, 'flex3sdk'
      end
    end

    context "that has been registered" do

      setup do
        @target = 'test/fixtures/process_runner/chmod_script.sh'
        Sprout.register_executable :mxmlc, 'flex3sdk', @target, '1.0.pre'
      end

      should "succeed if the tool is available and no version specified" do
        assert_equal @target, Sprout.get_executable(:mxmlc, 'flex3sdk')
      end

      should "succeed if version requirement is met" do
        assert_equal @target, Sprout.get_executable(:mxmlc, 'flex3sdk', '>= 1.0.pre')
      end

      should "fail if version requirement is not met" do
        assert_raises Sprout::Errors::VersionRequirementNotMetError do
          exe = Sprout.get_executable :mxmlc, 'flex3sdk', '>= 1.1.0'
        end
        
      end
    end

  end

end

