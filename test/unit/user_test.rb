require 'test_helper'

class UserTest < Test::Unit::TestCase
  #include SproutTestHelper

  ['vista', 'mswin', 'wince', 'emx'].each do |variant|
    context variant do
      should "create a Win System" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::System.create.is_a?(Sprout::System::WinSystem)
      end
    end
  end

=begin 

  ['cygwin', 'mingw', 'bccwin'].each do |variant|
    context variant do
      should "create a WinNix System" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::System.create.is_a?(Sprout::System::WinNixUser)
        assert Sprout::System.create.is_a?(Sprout::System::WinUser)
      end
    end
  end

  context "vista" do
    should "create a Vista System" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "vista"
      assert Sprout::System.create.is_a?(Sprout::System::VistaUser)
      assert Sprout::System.create.is_a?(Sprout::System::WinUser)
    end
  end

  ['solaris', 'redhat', 'ubuntu'].each do |variant|
    context variant do
       
      setup do
        @success_exec = File.join(fixtures, 'process_runner', 'success')
        @failure_exec = File.join(fixtures, 'process_runner', 'failure')
        @system = Sprout::System::UnixUser.new
        @process = FakeProcessRunner.new
        # Allows this test to run on Windows:
        @system.stubs(:get_process_runner).returns @process
      end
      
      should "create a Unix System" do
        Sprout::Platform.any_instance.stubs(:ruby_platform).returns variant
        assert Sprout::System.create.is_a?(Sprout::System::UnixUser)
      end
      
      should "execute external processes" do
        @system.execute @success_exec
      end

      should "handle execution errors" do
        # Write to the fake error stream:
        @process.read_err.write "Forced Error For test"
        assert_raises Sprout::Errors::ExecutionError do
          @system.execute @failure_exec
        end
      end
    end
  end

  context "osx" do
    should "create an OSX System" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "darwin"
      assert Sprout::System.create.is_a?(Sprout::System::OSXUser)
    end
  end

  context "java" do
    should "create a Java System" do
      Sprout::Platform.any_instance.stubs(:ruby_platform).returns "java"
      assert Sprout::System.create.is_a?(Sprout::System::JavaUser)
    end
  end

  context "any system" do

    setup do
      @system = Sprout::System::UnixUser.new
    end

    context "library path" do

      should "match the home path" do
        assert_not_nil @system.library
        assert_equal @system.home, @system.library
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
          @system.stubs(accessor).returns nil
        end
      end

      should "use env HOME" do
        @system.expects(:env_home).returns "abc"
        assert_equal 'abc', @system.home
      end

      should "use the env USERPROFILE" do
        @system.expects(:env_userprofile).returns "abc"
        assert_equal 'abc', @system.home
      end

      should "use the env HOMEPATH" do
        @system.expects(:env_homedrive).returns "c"
        @system.expects(:env_homepath).returns "abc"
        assert_equal 'c:abc', @system.home
      end

      should "use ~" do
        @system.expects(:tilde_home).returns "abc"
        assert_equal 'abc', @system.home
      end

      should "fallback to C drive" do
        @system.expects(:tilde_home).raises StandardError.new
        @system.expects(:alt_separator?).returns true
        assert_equal "C:\\", @system.home
      end

      should "fallback to unix root" do
        @system.expects(:tilde_home).raises StandardError.new
        @system.expects(:alt_separator?).returns false
        assert_equal "/", @system.home
      end
    end

  end
=end
end

