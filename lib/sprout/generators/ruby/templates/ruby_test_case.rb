require File.join(File.dirname(__FILE__), '..', 'test_helper')

class <%= input.camel_case %>Test < Test::Unit::TestCase
  include SproutTestCase

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

