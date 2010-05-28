require File.dirname(__FILE__) + '/test_helper'
require 'test/fixtures/examples/echo_inputs'

class ExecutableOptionParserTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new RDoc parser" do

    setup do
      @parser = Sprout::RDocParser.new
    end

  end
end

