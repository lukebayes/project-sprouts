require File.dirname(__FILE__) + '/test_helper'

class VistaUserTest < Test::Unit::TestCase
  include SproutTestCase

  context "new windows vista user" do

    setup do
      @user = Sprout::User::VistaUser.new
      @user.stubs(:env_userprofile).returns '/somehome'
    end

    should "find library" do
      File.stubs(:exists?).returns true
      assert_equal '/somehome/Local Settings/Application Data', @user.library
    end

    should "wrap paths that have spaces with escaped quotes" do
      assert_equal "\"foo bar\"", @user.clean_path("foo bar")
    end

    should "not modify paths that have no spaced" do
      assert_equal "foobar", @user.clean_path("foobar")
    end

  end
end

