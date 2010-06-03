require File.dirname(__FILE__) + '/test_helper'

class UnixSystemTest < Test::Unit::TestCase
  include SproutTestCase

  context "new unix system" do

    setup do
      @user = Sprout::System::UnixSystem.new
      @user.stubs(:home).returns '/home/someone'
    end

    should "escape spaces in paths" do
      assert_equal 'a\ b', @user.clean_path('a b')
    end

    should "snake case application name" do
      assert_equal '.foo_bar', @user.format_application_name('Foo Bar')
    end

    should "have home" do
      assert_equal '/home/someone', @user.home
    end

    should "have library" do
      assert_equal '/home/someone', @user.library
    end

    should "format application home" do
      assert_equal '/home/someone/.sprouts', @user.application_home('Sprouts')
    end

    context "when fed an application with windows line endings" do

      setup do
        @source = File.join fixtures, 'executable', 'windows_line_endings'
        @target = File.join fixtures, 'executable', 'windows_line_endings.tmp'
        FileUtils.cp @source, @target
      end

      teardown do
        remove_file @target
      end

      should "fix windows line endings" do
        @user.expects :repair_executable
        @user.clean_path @target
      end
    end
  end
end

