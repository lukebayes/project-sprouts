require File.dirname(__FILE__) + '/test_helper'

class WinNixUserTest < Test::Unit::TestCase
  include SproutTestCase

  context "new windows nix (cygwin/mingw) user" do

    setup do
      @user = Sprout::User::WinNixUser.new
      @user.stubs(:win_home).returns 'C:\Documents and Settings\Some User'
    end

    should "find home" do
      assert_equal '/cygdrive/c/Documents and Settings/Some User', @user.home
    end

    should "wrap paths that have spaces with escaped quotes" do
      assert_equal "\'foo bar\'", @user.clean_path("foo bar")
    end

    should "not modify paths that have no spaced" do
      assert_equal "foobar", @user.clean_path("foobar")
    end
  end
end

