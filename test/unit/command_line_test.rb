require 'test_helper'

class CommandLineTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new command line ui" do
    
    setup do
      @instance = Sprout::CommandLine.new
      @instance.logger = Sprout::OutputBuffer.new
    end

    should "display the version number" do
      @instance.version = true
      @instance.execute

      assert_matches /sprout #{Sprout::VERSION::STRING}/, @instance.logger.read
    end
  end
end


