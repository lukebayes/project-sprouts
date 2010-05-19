require File.dirname(__FILE__) + '/test_helper'

class UnixUserTest < Test::Unit::TestCase
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
  end
end

