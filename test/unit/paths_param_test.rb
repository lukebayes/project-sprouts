require File.dirname(__FILE__) + '/test_helper'

class PathsParamTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new PathsParam" do

    setup do
      @path1 = File.join(fixtures, 'tool', 'paths', 'folder1')
      @path2 = File.join(fixtures, 'tool', 'paths', 'folder2')
      @path3 = File.join(fixtures, 'tool', 'paths', 'folder3')

      @param = Sprout::PathsParam.new
      @param.belongs_to = FakeTool.new
      @param.name = 'paths'
    end

    should "accept a collection of paths" do
      @param.value << @path1
      @param.value << @path2
      @param.value << @path3

      assert_equal "-paths+=#{@path1} -paths+=#{@path2} -paths+=#{@path3}", @param.to_shell
      # All child files have been added as prerequisites:
      assert_equal 6, @param.belongs_to.prerequisites.size
    end

    should "accept a custom file expression" do
    end

    should "accept hidden_name parameter" do
    end

  end
end

