require File.dirname(__FILE__) + '/test_helper'

class StringsParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new StringsParam" do

    setup do
      @param = Sprout::Executable::Strings.new
      @param.name = "strings"
    end

    ['abcd', 1234, true].each do |value|
      should "throw with non-enumerable assignment of #{value}" do
        assert_raises Sprout::Errors::ExecutableError do
          @param.value = value
        end
      end
    end

    should "not escape spaces" do
      @param.value << "a b c"
      assert_equal '-strings+=a b c', @param.to_shell
    end
  end
end

