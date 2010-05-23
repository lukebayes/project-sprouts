require File.dirname(__FILE__) + '/test_helper'

class BooleanParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new, simple BooleanParam" do

    setup do 
      @param = Sprout::Executable::Boolean.new
      @param.name = 'foo'
    end

    should "be hidden when false" do
      @param.value = false
      assert_equal '', @param.to_shell
    end

    should "default to false" do
      assert_equal false, @param.value
    end

    should "show on true" do
      @param.value = true
      assert_equal '--foo', @param.to_shell
    end

    context "when configuring option parser" do
      
      should "update correctly" do
        @param.show_on_false = true
        @param.default = true
        @param.hidden_value = false
        assert_equal "--foo [BOOL]", @param.option_parser_declaration
      end
    end
  end
end

