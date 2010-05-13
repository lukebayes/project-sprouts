require File.dirname(__FILE__) + '/test_helper'

class FilesParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new FilesParam" do

    setup do
      @input1 = File.join(fixtures, "tool", "params", "input.as")
      @input2 = File.join(fixtures, "tool", "params", "input2.as")
      @input3 = File.join(fixtures, "tool", "params", "input3.as")

      @param = Sprout::Tool::FilesParam.new
      @param.name = 'inputs'
      @param.belongs_to = FakeToolTask.new
    end

    ['abcd', 1234, true].each do |value|
      should "throw with non-enumerable assignment of #{value}" do
        assert_raises Sprout::Errors::ToolError do
          @param.value = value
        end
      end
    end

    should "allow assignment of enumerables" do
      @param.value = ['abcd', 'efgh']
    end

    should "allow concatenation on first access" do
      @param.value << 'abcd'
    end

    should "clean each path provided" do
      # Ensure order is retained:
      @param.value << @input3
      @param.value << @input2
      @param.value << @input1
      
      assert_equal "-inputs+=#{@input3} -inputs+=#{@input2} -inputs+=#{@input1}", @param.to_shell
    end

    should "defer to to_shell_proc if provided" do
      @param.to_shell_proc = Proc.new { |param|
        "proc:#{param.name}:#{param.value.shift}"
      }

      @param.value << 'abcd'

      assert "Should be visible", @param.visible?
      assert_equal 'proc:inputs:abcd', @param.to_shell
    end

  end
end

