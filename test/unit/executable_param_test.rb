require File.dirname(__FILE__) + '/test_helper'

class ExecutableParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new, simple Executable::Param" do

    setup do 
      @param = Sprout::Executable::Param.new
    end

    should "be invisible until value set" do
      assert !@param.visible?
    end

    should "return empty string with no value" do
      assert_equal '', @param.to_shell
    end

    should "raise if required and nil" do
      @param.required = true
      assert_raises Sprout::Errors::ToolError do
        @param.to_shell
      end
    end

    context "with simple values" do

      setup do
        @param.name = :foo
        @param.value = 'bar'
      end

      should "not raise if required and has value" do
        @param.required = true
        assert @param.to_shell
      end

      should "accept a name and value" do
        assert_equal '-foo=bar', @param.to_shell
      end

      should "accept space delimiter" do
        @param.delimiter = ' '
        assert_equal '-foo bar', @param.to_shell
      end

      should "accept arbitrary delimiter" do
        @param.delimiter = ' ||= '
        assert_equal '-foo ||= bar', @param.to_shell
      end

      should "accept empty prefix" do
        @param.prefix = ''
        assert_equal 'foo=bar', @param.to_shell
      end

      should "accept arbitrary prefix" do
        @param.prefix = '++++'
        assert_equal '++++foo=bar', @param.to_shell
      end

      should "accept hidden_name attribute" do
        @param.hidden_name = true
        assert_equal 'bar', @param.to_shell
      end

      should "accept hidden_value attribute" do
        @param.hidden_value = true
        assert_equal '-foo', @param.to_shell
      end

    end
  end
end

