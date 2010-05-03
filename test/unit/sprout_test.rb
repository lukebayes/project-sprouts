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

end

