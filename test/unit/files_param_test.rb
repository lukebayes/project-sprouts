require File.dirname(__FILE__) + '/test_helper'

class FilesParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new FilesParam" do

    setup do
      @input1 = File.join(fixtures, "executable", "params", "input.as")
      @input2 = File.join(fixtures, "executable", "params", "input2.as")
      @input3 = File.join(fixtures, "executable", "params", "input3.as")

      @input4 = File.join(fixtures, "executable", "path with spaces", "input.as")
      @input5 = File.join(fixtures, "executable", "path with spaces", "input2.as")
      @input6 = File.join(fixtures, "executable", "path with spaces", "input3.as")

      @param = Sprout::Executable::Files.new
      @param.name = 'inputs'
      @param.belongs_to = FakeExecutableTask.new
    end

    ['abcd', 1234, true].each do |value|
      should "throw with non-enumerable assignment of #{value}" do
        assert_raises Sprout::Errors::ExecutableError do
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
      
      as_each_system do |sys|
        assert_equal "-inputs+=#{sys.clean_path(@input3)} -inputs+=#{sys.clean_path(@input2)} -inputs+=#{sys.clean_path(@input1)}", @param.to_shell, "As a Unix System"
      end
    end

    should "clean paths with spaces" do
      @param.value << @input6
      @param.value << @input5
      @param.value << @input4
      
      as_each_system do |sys|
        assert_equal "-inputs+=#{sys.clean_path(@input6)} -inputs+=#{sys.clean_path(@input5)} -inputs+=#{sys.clean_path(@input4)}", @param.to_shell, "As a Unix System"
      end
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

