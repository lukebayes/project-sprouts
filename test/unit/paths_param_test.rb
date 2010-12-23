require 'test_helper'

class PathsParamTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new PathsParam" do

    setup do
      @path1 = File.join(fixtures, 'executable', 'paths', 'folder1')
      @path2 = File.join(fixtures, 'executable', 'paths', 'folder2')
      @path3 = File.join(fixtures, 'executable', 'paths', 'folder3')

      @param = Sprout::Executable::Paths.new
      @param.belongs_to = FakeExecutableTask.new
      @param.name = 'paths'
    end

    should "accept a collection of paths" do
      @param.value << @path1
      @param.value << @path2
      @param.value << @path3

      as_each_system do |sys|
        assert_equal "-paths+=#{sys.clean_path(@path1)} -paths+=#{sys.clean_path(@path2)} -paths+=#{sys.clean_path(@path3)}", @param.to_shell
      end

      # All child files have been added as prerequisites:
      assert_equal 6, @param.belongs_to.prerequisites.size
    end

    should "accept a custom file expression" do
      @param.file_expression = "file2"
      @param.value << @path1

      as_each_system do |sys|
        assert_equal "-paths+=#{sys.clean_path(@path1)}", @param.to_shell
      end

      # All child files have been added as prerequisites:
      assert_equal 1, @param.belongs_to.prerequisites.size
    end

    should "accept hidden_name parameter" do
      @param.hidden_name = true
      @param.value << @path1
      assert_equal @path1, @param.to_shell
      # All child files have been added as prerequisites:
      assert_equal 3, @param.belongs_to.prerequisites.size
    end

  end
end

