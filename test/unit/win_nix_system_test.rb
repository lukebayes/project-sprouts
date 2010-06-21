require File.dirname(__FILE__) + '/test_helper'

class WinNixSystemTest < Test::Unit::TestCase
  include SproutTestCase

  context "new windows nix (cygwin/mingw) system" do

    setup do
      @sys = Sprout::System::WinNixSystem.new
      @sys.stubs(:win_home).returns 'C:\Documents and Settings\Some System'
    end

    should "find home on cygwin" do
      File.stubs(:exists?).returns false
      assert_equal '/cygdrive/c/Documents and Settings/Some System', @sys.home
    end

    should "find home on mingw" do
      File.stubs(:exists?).returns true
      assert_equal 'C:/Documents and Settings/Some System', @sys.home
    end

    should "wrap paths that have spaces with escaped quotes" do
      assert_equal "\"foo bar\"", @sys.clean_path("foo bar")
    end

    should "not modify paths that have no spaced" do
      assert_equal "foobar", @sys.clean_path("foobar")
    end
  end
end

