require File.dirname(__FILE__) + '/test_helper'

class SproutTest < Test::Unit::TestCase

  context "With Sprout Errors" do
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

  context "With Sprout base" do
    should "be able to instantiate it" do
      base = Sprout::Base.new
    end
  end

end

