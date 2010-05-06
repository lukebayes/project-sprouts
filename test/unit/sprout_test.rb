require File.dirname(__FILE__) + '/test_helper'

class SproutTest < Test::Unit::TestCase
  include SproutTestCase

  context "Errors" do
    include Sprout::Errors

    [
      ArchiveUnpackerError,
      DestinationExistsError,
      ExecutionError, 
      ExecutableRegistrationError,
      MissingExecutableError,
      ProcessRunnerError,
      SproutError, 
      ToolError,
      ToolError,
      UnknownArchiveType,
      UsageError,
      VersionRequirementNotMetError
    ].each do |error|

      should "be available to instiate a #{error.to_s}" do
        error.new
      end
    end
  end

  context "Executables" do
    setup do
      Sprout.stubs(:require_executable).returns true
      @target = 'test/fixtures/process_runner/chmod_script.sh'
    end

    should "fail when registered with same name and different versions" do
      Sprout.register_executable :mxmlc, 'flex3sdk', '1.0.0', @target
      assert_raises Sprout::Errors::ExecutableRegistrationError do
        Sprout.register_executable :mxmlc, 'flex3sdk', '1.0.pre', @target
      end
    end

    should "work when registered with different gem names" do
      Sprout.register_executable :mxmlc, 'flex3sdk', '1.0.pre', @target
      Sprout.register_executable :mxmlc, 'flex4sdk', '1.0.pre', @target
    end

    should "work when registered with different exe names" do
      Sprout.register_executable :mxmlc, 'flex3sdk', '1.0.pre', @target
      Sprout.register_executable :compc, 'flex3sdk', '1.0.pre', @target
    end

    context "that are registered" do
      should "work the first time" do
        Sprout.register_executable :mxmlc, 'flex3sdk', '1.0.pre', @target
      end

      context "and then requested" do
        setup do
          Sprout.register_executable :mxmlc, 'flex3sdk', '1.0.pre', @target
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

    context "that are not registered" do

      should "fail when requested" do
        assert_raises Sprout::Errors::MissingExecutableError do
          exe = Sprout.get_executable :mxmlc, 'flex3sdk'
        end
      end

    end

  end
end


