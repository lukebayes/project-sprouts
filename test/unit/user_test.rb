require File.dirname(__FILE__) + '/test_helper'

class UserTest < Test::Unit::TestCase
  include SproutTestCase

  ['vista', 'mswin', 'wince', 'emx'].each do |variant|
    context variant do
      should "create a Win User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::Win)
      end
    end
  end
  
  ['cygwin', 'mingw', 'bccwin'].each do |variant|
    context variant do
      should "create a WinNix User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::WinNix)
        assert Sprout::User.create.is_a?(Sprout::User::Win)
      end
    end
  end

  context "vista" do
    should "create a Vista User" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "vista"
      assert Sprout::User.create.is_a?(Sprout::User::Vista)
      assert Sprout::User.create.is_a?(Sprout::User::Win)
    end
  end

  ['solaris', 'redhat', 'ubuntu'].each do |variant|
    context variant do
      should "create a Unix User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::Unix)
      end
    end
  end

  context "osx" do
    should "create an OSX User" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "darwin"
      assert Sprout::User.create.is_a?(Sprout::User::OSX)
    end
  end

  context "java" do
    should "create a Java User" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "java"
      assert Sprout::User.create.is_a?(Sprout::User::Java)
    end
  end

  context "any user" do

    setup do
      @user = Sprout::User::Unix.new
      # Block all of the automatic path introspection:
      [
        :env_userprofile, 
        :env_home, 
        :env_homedrive, 
        :env_homepath, 
        :tilde_home, 
        :alt_separator?
      ].each do |accessor|
        @user.stubs(accessor).returns nil
      end
    end

    should "find the env home" do
      @user.expects(:env_home).returns "abc"
      assert_equal 'abc', @user.home
    end

    should "find the env userprofile" do
      @user.expects(:env_userprofile).returns "abc"
      assert_equal 'abc', @user.home
    end

    should "find the env homepath" do
      @user.expects(:env_homedrive).returns "c"
      @user.expects(:env_homepath).returns "abc"
      assert_equal 'c:abc', @user.home
    end

    should "attempt to use ~" do
      @user.expects(:tilde_home).returns "abc"
      assert_equal 'abc', @user.home
    end

    should "fallback to C drive" do
      @user.expects(:tilde_home).raises StandardError.new
      @user.expects(:alt_separator?).returns true
      assert_equal "C:\\", @user.home
    end

    should "fallback to unix root" do
      @user.expects(:tilde_home).raises StandardError.new
      @user.expects(:alt_separator?).returns false
      assert_equal "/", @user.home
    end
  end

end



=begin
  context "a user" do
    
    setup do
      @fixture = File.expand_path(File.join(fixtures, 'user'))
      @mxmlc_crlf = File.join(@fixture, 'mxmlc_crlf')
      @mxmlc = File.join(@fixture, 'mxmlc')
      FileUtils.cp(@mxmlc_crlf, @mxmlc);
    end

    teardown do
      remove_file @mxmlc
    end

    [
      {:os => :win32,   :impl => :vista,    :user => Sprout::VistaUser},
      {:os => :win32,   :impl => :cygwin,   :user => Sprout::CygwinUser},
      {:os => :win32,   :impl => :unknown,  :user => Sprout::WinUser},
      {:os => :win32,   :impl => :windows7, :user => Sprout::WinUser},
      {:os => :unix,    :impl => :macosx,   :user => Sprout::OSXUser},
      {:os => :unix,    :impl => :solaris,  :user => Sprout::UnixUser},
      {:os => :unix,    :impl => :freebsd,  :user => Sprout::UnixUser},
      {:os => :unknown, :impl => :unknown,  :user => Sprout::UnixUser}
    ].each do |platform|
      context "Instantiating a user with OS: #{platform[:os]} and impl: #{platform[:impl]}" do

        should "create the correct user type" do
          user = Sprout::User.new platform[:os], platform[:impl]
          assert_not_nil user
          assert_equal platform[:user], user.class
        end

        should "use the values from Platform" do
          Platform::OS = platform[:os]
          Platform::IMPL = platform[:impl]

          user = Sprout::User.new # no args
          assert_equal platform[:user], user.class
        end

      end
    end

    should "allow default user to be assigned" do
      Sprout::User.user = FakeUser.new
      user = Sprout::User.new
      assert_equal FakeUser, user.class
    end

    should "fix crlf (Windows) line endings in an executable for nix users" do
      user = Sprout::UnixUser.new
      output = user.execute @mxmlc
      assert_not_nil output, "Output should not be nil"
      assert output.match(/success/)
    end
  end
end

class FakeUser; end
=end

