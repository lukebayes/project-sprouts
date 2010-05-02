require File.dirname(__FILE__) + '/test_helper'

class ToolTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new tool" do

    setup do
      @tool = FakeTool.new
    end

    should "accept boolean param" do
      @tool.debug = true
      assert @tool.debug
    end

    should "accept a string param" do
      @tool.str = "abcd"
      assert_equal "abcd", @tool.str
      assert_equal "-str=abcd", @tool.to_shell
    end

    should "accept strings param" do
      @tool.strs << 'abcd'
      @tool.strs << 'efgh'
      @tool.source_path << 'lib'

      assert_equal ['abcd', 'efgh'], @tool.strs
      assert_equal "-str=abcd -strs+=abcd -strs+=efgh -debug=true -source-path+=lib", @tool.to_shell
    end

    should "raise helpful error when treating collections like singles" do
    end
  end

end

class FakeTool
  include Sprout::Tool

  add_param :str, :string
  add_param :strs, :strings

  add_param :debug, :boolean do |p|
    p.description = "Set the debug flag"
  end

  add_param :source_path, :files do |p|
    p.description = "Add files to the source path"
  end

end


