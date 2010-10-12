require 'test_helper'

class SpecificationTest < Test::Unit::TestCase
  include SproutTestCase

  context "a newly defined specification" do
    setup do
      @spec = Sprout::Specification.new do |s|
        s.version = '1.0.pre'
      end
    end

    should "have a default name" do
      assert_equal 'specification_test', @spec.name
    end

    should "accept the version" do
      assert_equal '1.0.pre', @spec.version
    end

    context "with a new name" do
      setup do
        @spec.name    = 'foo_sdk'
        @spec.version = '1.0.pre'
      end

      should "register executables with file_target reference" do
        @spec.add_file_target do |t|
          t.add_executable :foo, 'bin/foo'
        end

        Sprout::Executable.stubs :require_ruby_package
        exe = Sprout::Executable.load :foo, 'foo_sdk', '1.0.pre'
        assert_equal Sprout::FileTarget, exe.file_target.class
      end

      should "register executable with remote_file_target instances" do
        @spec.add_remote_file_target do |t|
          t.url = 'http://www.example.com'
          t.md5 = 'abcd'
          t.archive_type = :zip
          t.add_executable :foo, 'bin/foo'
        end

        Sprout::RemoteFileTarget.any_instance.stubs :resolve
        Sprout::Executable.stubs :require_ruby_package
        exe = Sprout::Executable.load :foo, 'foo_sdk', '1.0.pre'
        assert_equal Sprout::RemoteFileTarget, exe.file_target.class
        assert exe.path =~ /cache/, "RemoteFileTarget local path should include Sprout CACHE directory"
      end

      should "load returns libraries in expected order" do
        @spec.add_file_target do |t|
          t.add_library :swc, 'bin/foo'
          t.add_library :src, 'bin/bar'
        end

        # Without specifying the :swc/:src decision:
        library = Sprout::Library.load nil, 'foo_sdk'
        assert_equal 'foo', File.basename(library.path)
      end
     
    end
  end

  context "a platform-specific, remote executable specification" do

    setup do
      @spec = Sprout::Specification.new do |s|
        s.name = 'fake_flashplayer_spec'
        s.version = '10.1.53'

        s.add_remote_file_target do |t|
          t.platform     = :windows
          t.add_executable :fake_flashplayer, "flashplayer_10_sa_debug.exe"
        end

        s.add_remote_file_target do |t|
          t.platform     = :osx
          t.add_executable :fake_flashplayer, "Flash Player Debugger.app"
        end

        s.add_remote_file_target do |t|
          t.platform     = :linux
          t.add_executable :fake_flashplayer, "flashplayerdebugger"
        end
      end

    end

    should "be resolved for Windows systems" do
      Sprout::RemoteFileTarget.any_instance.expects(:resolve)
      as_a_windows_system do
        target = Sprout::Executable.load 'fake_flashplayer'
        assert_equal :windows, target.platform
      end
    end

    should "be resolved for OSX systems" do
      Sprout::RemoteFileTarget.any_instance.expects(:resolve)
      as_a_mac_system do
        target = Sprout::Executable.load 'fake_flashplayer'
        assert_equal :osx, target.platform
      end
    end

    should "be resolved for Unix systems" do
      Sprout::RemoteFileTarget.any_instance.expects(:resolve)
      as_a_unix_system do
        target = Sprout::Executable.load 'fake_flashplayer'
        assert_equal :linux, target.platform
      end
    end
  end

  context "a universal collection of executables" do

    setup do
      @spec = Sprout::Specification.new do |s|
        s.name    = 'flex4'
        s.version = '4.0.pre'

        s.add_remote_file_target do |t|
          # Apply the windows-specific configuration:
          t.platform = :universal
          # Apply the shared platform configuration:
          # Remote Archive:
          t.archive_type = :zip
          t.url          = "http://download.macromedia.com/pub/labs/flex/4/flex4sdk_b2_100509.zip"
          t.md5          = "6a0838c5cb33145fe88933778ddb966d"

          # Executables: (add .exe suffix if it was passed in)
          t.add_executable :compc,      "bin/compc"
          t.add_executable :fcsh,       "bin/fcsh"
          t.add_executable :fdb,        "bin/fdb"
          t.add_executable :mxmlc,      "bin/mxmlc"
        end
      end

    end

    should "make binaries available" do
      mxmlc = Sprout::Executable.load :mxmlc
      assert_not_nil mxmlc
    end
  end

  context "a newly included executable" do
    setup do
      @echo_chamber = File.join fixtures, 'executable', 'echochamber_gem', 'echo_chamber'
      $:.unshift File.dirname(@echo_chamber)
    end

    teardown do
      $:.shift
    end

    should "require the sproutspec" do
      path = Sprout::Executable.load(:echos, 'echo_chamber').path
      assert_matches /fixtures\/.*echochamber/, path
      assert_file path

      # TODO: We should be able to execute
      # the provided executable!
      #response = Sprout::System.create.execute path
      #assert_equal 'ECHO ECHO ECHO', response
    end
  end
end

