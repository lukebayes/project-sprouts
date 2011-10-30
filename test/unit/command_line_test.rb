require 'test_helper'

class CommandLineTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new command line ui" do

    setup do
      @logger          = Sprout::OutputBuffer.new
      @instance        = Sprout::CommandLine.new
      @instance.logger = @logger
    end

    should "display the version number" do
      @instance.parse! ['--version']
      @instance.execute
      assert_matches /sprout #{Sprout::VERSION::STRING}/, @logger.read
    end

    should "display helper if no options provided" do
      @instance.expects :abort
      @instance.parse! []
    end
  end
end


