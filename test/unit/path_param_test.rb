require File.dirname(__FILE__) + '/test_helper'

class PathParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new PathParam" do

    setup do
      @path1 = File.join(fixtures, 'tool', 'paths', 'folder1')

      @param = Sprout::PathParam.new
      @param.belongs_to = FakeToolTask.new
      @param.name = 'path'
    end

    should "accept a collection of paths" do
      @param.value = @path1

      assert_equal "-path=#{@path1}", @param.to_shell
      # All child files have been added as prerequisites:
      assert_equal 3, @param.belongs_to.prerequisites.size
    end

    should "accept a custom file expression" do
      @param.file_expression = "file2"
      @param.value = @path1
      assert_equal "-path=#{@path1}", @param.to_shell
      # All child files have been added as prerequisites:
      assert_equal 1, @param.belongs_to.prerequisites.size
    end

    should "accept hidden_name parameter" do
      @param.hidden_name = true
      @param.value = @path1
      assert_equal @path1, @param.to_shell
      # All child files have been added as prerequisites:
      assert_equal 3, @param.belongs_to.prerequisites.size
    end

  end
end


