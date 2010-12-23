require 'test_helper'
require 'fixtures/examples/echo_inputs'

class ExecutableOptionParserTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new RDoc parser" do

    setup do
      @parser = Sprout::RDocParser.new
    end

  end
end

