require File.dirname(__FILE__) + '/test_helper'

class PathsParamTest < Test::Unit::TestCase
  include SproutTestCase

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

      as_a_unix_system do
        sys = Sprout::System::UnixSystem.new
        assert_equal "-paths+=#{sys.clean_path(@path1)} -paths+=#{sys.clean_path(@path2)} -paths+=#{sys.clean_path(@path3)}", @param.to_shell
      end

      as_a_windows_system do
        sys = Sprout::System::WinSystem.new
        assert_equal "-paths+=#{sys.clean_path(@path1)} -paths+=#{sys.clean_path(@path2)} -paths+=#{sys.clean_path(@path3)}", @param.to_shell
      end

      # All child files have been added as prerequisites:
      assert_equal 6, @param.belongs_to.prerequisites.size
    end

    should "accept a custom file expression" do
      @param.file_expression = "file2"
      @param.value << @path1
      assert_equal "-paths+=#{@path1}", @param.to_shell
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

