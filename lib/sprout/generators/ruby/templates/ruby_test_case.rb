require 'test_helper'

class <%= input.camel_case %>Test < Test::Unit::TestCase
  include Sprout::TestHelper

  context "A <%= input.camel_case %>" do

    setup do
      @fixture = File.join fixtures, '<%= input.snake_case %>', 'tmp'
      FileUtils.makedirs @fixture
    end

    teardown do
      remove_file @fixture
    end

    should "do something" do
      assert_file @fixture
      assert false, 'Force test failure'
    end
  end
end

