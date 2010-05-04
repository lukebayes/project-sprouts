require File.dirname(__FILE__) + '/test_helper'

class ToolTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new tool" do

    setup do
      @tool = FakeTool.new
    end

    # TODO: Test each parameter type:

    should "accept boolean param" do
      @tool.boolean_param = true
      assert @tool.boolean_param
      assert_equal "-boolean-param=true", @tool.to_shell
    end

    should "accept a string param" do
      @tool.string_param = "string1"
      assert_equal "string1", @tool.string_param
      assert_equal "-string-param=string1", @tool.to_shell
    end

    should "accept strings param" do
      @tool.strings_param << 'string1'
      @tool.strings_param << 'string2'

      assert_equal ['string1', 'string2'], @tool.strings_param
      assert_equal "-strings-param+=string1 -strings-param+=string2", @tool.to_shell
    end

    should "raise UsageError with unknown type" do

      assert_raises Sprout::Errors::UsageError do
        class BrokenTool
          include Sprout::Tool
          add_param :broken_param, :unknown_type
        end

        tool = BrokenTool.new
      end
    end

    context "with a custom param (defined below)" do
      should "attempt to instantiate by adding _param to the end" do
        assert_not_nil Sprout::ParameterFactory.create :custom
      end
      should "attempt to instantiate an unknown type before failing" do
        assert_not_nil Sprout::ParameterFactory.create :custom_param
      end
    end

    # TODO: Ensure that file, files, path and paths
    # validate the existence of the references.

    # TODO: Ensure that a helpful error message is thrown
    # when assignment operator is used on collection params
  end

end

class CustomParam < Sprout::ToolParam; end

class FakeTool
  include Sprout::Tool

  add_param :boolean_param, :boolean
  add_param :file_param,    :file
  add_param :files_param,   :files
  add_param :path_param,    :path
  add_param :paths_param,   :paths
  add_param :string_param,  :string
  add_param :strings_param, :strings 
  add_param :symbols_param, :symbols
  add_param :urls_param,    :urls

end


