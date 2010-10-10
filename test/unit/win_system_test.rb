require 'test_helper'

class WinSystemTest < Test::Unit::TestCase
  include SproutTestCase

  context "new windows system" do

    setup do
      @user = Sprout::System::WinSystem.new
    end

    should "not accept home path with My Documents" do
      @user.stubs(:find_home).returns File.join('C:', 'foo', 'My Documents')
      assert_equal File.join('C:', 'foo'), @user.home
    end

    should "return env_path" do
      @user.stubs(:env_path).returns "a;b;c;"
      assert_equal ['a', 'b', 'c'], @user.get_paths
    end

    should "execute with correct implementation" do
      @echochamber = File.join fixtures, 'remote_file_target', 'bin', 'echochamber'
      # Don't actually call the win32 execute function:
      r = StringIO.new
      w = StringIO.new
      e = StringIO.new
      pid = nil
      Sprout::ProcessRunner.any_instance.expects(:io_popen_block).returns([pid, w, r, e])
      @user.stubs(:clean_path).returns @echochamber
      @user.execute @echochamber
    end

    context "with home already set" do

      setup do
        @user.stubs(:home).returns 'C:\Documents and Settings\Some System'
      end

      should "find library" do
        File.stubs(:exists?).returns true
        assert_matches /Local Settings\/Application Data/, @user.library
      end

      should "find library outside home" do
        File.stubs(:exists?).returns false
        assert "Shouldn't use app data if it doesn't exist", (@user.library =~ /Application Data/).nil?
      end

      should "wrap paths that have spaces with escaped quotes" do
        assert_equal "\"foo bar\"", @user.clean_path("foo bar")
      end

      should "not modify paths that have no spaced" do
        assert_equal "foobar", @user.clean_path("foobar")
      end
    end

  end
end

