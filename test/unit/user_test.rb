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
       
      setup do
        @user = Sprout::User::Unix.new
        @user.stubs(:get_process_runner).returns FakeProcessRunner.new
      end
      
      should "create a Unix User" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::User.create.is_a?(Sprout::User::Unix)
      end
      
      should "execute external processes" do
        #@user.execute 'abcd'
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

