require File.dirname(__FILE__) + '/test_helper'

class UserTest < Test::Unit::TestCase
  include SproutTestCase

  ['vista', 'mswin', 'wince', 'emx'].each do |variant|
    context variant do
      should "create a Win User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::WinUser)
      end
    end
  end
  
  ['cygwin', 'mingw', 'bccwin'].each do |variant|
    context variant do
      should "create a WinNix User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::WinNixUser)
        assert Sprout::User.create.is_a?(Sprout::User::WinUser)
      end
    end
  end

  context "vista" do
    should "create a Vista User" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "vista"
      assert Sprout::User.create.is_a?(Sprout::User::VistaUser)
      assert Sprout::User.create.is_a?(Sprout::User::WinUser)
    end
  end

  ['solaris', 'redhat', 'ubuntu'].each do |variant|
    context variant do
       
      setup do
        @success_exec = File.join(fixtures, 'process_runner', 'success')
        @failure_exec = File.join(fixtures, 'process_runner', 'failure')
        @user = Sprout::User::UnixUser.new
        @process = FakeProcessRunner.new
        # Allows this test to run on Windows:
        @user.stubs(:get_process_runner).returns @process
      end
      
      should "create a Unix User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::UnixUser)
      end
      
      should "execute external processes" do
        @user.execute @success_exec
      end

      should "handle execution errors" do
        # Write to the fake error stream:
        @process.read_err.write "Forced Error For test"
        assert_raises Sprout::Errors::ExecutionError do
          @user.execute @failure_exec
        end
      end
    end
  end

  context "osx" do
    should "create an OSX User" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "darwin"
      assert Sprout::User.create.is_a?(Sprout::User::OSXUser)
    end
  end

  context "java" do
    should "create a Java User" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "java"
      assert Sprout::User.create.is_a?(Sprout::User::JavaUser)
    end
  end

  context "any user" do

    setup do
      @user = Sprout::User::UnixUser.new
    end

    context "library path" do

      should "match the home path" do
        assert_not_nil @user.library
        assert_equal @user.home, @user.library
      end
    end

    context "home path" do

      setup do
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

      should "use env HOME" do
        @user.expects(:env_home).returns "abc"
        assert_equal 'abc', @user.home
      end

      should "use the env USERPROFILE" do
        @user.expects(:env_userprofile).returns "abc"
        assert_equal 'abc', @user.home
      end

      should "use the env HOMEPATH" do
        @user.expects(:env_homedrive).returns "c"
        @user.expects(:env_homepath).returns "abc"
        assert_equal 'c:abc', @user.home
      end

      should "use ~" do
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
end

