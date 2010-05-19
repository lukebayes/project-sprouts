require File.dirname(__FILE__) + '/test_helper'

class FileParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new FileParam" do

    setup do
      @input_with_spaces = File.join(fixtures, "tool", "path with spaces", "input.as")
      @input_with_spaces.gsub!(Dir.pwd + '/', '')
      @input_with_spaces_cleaned = @input_with_spaces.gsub(' ', '\ ')

      @input = File.join(fixtures, "tool", "params", "input.as")

      @tool = FakeToolTask.new

      @param = Sprout::Tool::FileParam.new
      @param.belongs_to = @tool
      @param.name = 'input'
      @param.value = @input
    end

    should "clean the path for current platform" do
      #as_a_unix_user do
        @param.expects(:validate)
        # Ensure that system.clean_path is called
        @param.value = @input_with_spaces
        @param.prepare
        assert_equal "-input=#{@input_with_spaces_cleaned}", @param.to_shell
      #end
    end

    should "include file path in shell output" do
      assert_equal "-input=#{@input}", @param.to_shell
    end

    should "add file as prerequisite to parent" do
      assert_equal 0, @tool.prerequisites.size
      @param.prepare
      assert_equal 1, @tool.prerequisites.size
    end

    should "not add prerequisite that matches name of parent" do
      @tool.name = :abcd
      @param.value = "abcd"
      @param.prepare
      assert_equal 0, @tool.prerequisites.size
    end

    should "raise if the file doesn't exist when asked for output" do
      @param.value = 'unknown file'
      assert_raises Sprout::Errors::ToolError do
        @param.to_shell
      end
    end

    should "preprocess if necessary" do
      @param.stubs(:should_preprocess?).returns true
      @param.stubs(:validate).returns nil
      @param.expects(:prepare_preprocessor_file).returns 'abcd'
      assert_equal '-input=abcd', @param.to_shell
    end
  end
end

