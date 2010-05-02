require File.dirname(__FILE__) + '/test_helper'

class BooleanParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new, simple BooleanParam" do

    setup do 
      @param = Sprout::BooleanParam.new
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
      assert_equal '-foo=true', @param.to_shell
    end
  end
end

