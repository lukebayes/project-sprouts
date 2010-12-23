require 'test_helper'

class VistaSystemTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "new windows vista system" do

    setup do
      @user_system = Sprout::System::VistaSystem.new
    end

    should "work when env_userprofile isn't found" do
      @user_system.stubs(:find_home).returns 'C:\Documents and Settings\Some System'
      File.stubs(:exists?).returns true
      assert_equal 'C:\Documents and Settings\Some System/Local Settings/Application Data', @user_system.library
    end

    context "with a valid userprofile" do

      setup do
        @user_system.stubs(:env_userprofile).returns '/somehome'
      end

      should "find library" do
        File.stubs(:exists?).returns true
        assert_equal '/somehome/Local Settings/Application Data', @user_system.library
      end

      should "wrap paths that have spaces with escaped quotes" do
        assert_equal "\"foo bar\"", @user_system.clean_path("foo bar")
      end

      should "not modify paths that have no spaced" do
        assert_equal "foobar", @user_system.clean_path("foobar")
      end
    end

  end
end

