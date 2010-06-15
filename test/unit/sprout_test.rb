require File.dirname(__FILE__) + '/test_helper'

class SproutTest < Test::Unit::TestCase
  include SproutTestCase

  context "Errors" do
    include Sprout::Errors

    [
      ArchiveUnpackerError,
      DestinationExistsError,
      ExecutionError, 
      ExecutableRegistrationError,
      MissingExecutableError,
      ProcessRunnerError,
      SproutError, 
      ExecutableError,
      UnknownArchiveType,
      UsageError,
      VersionRequirementNotMetError
    ].each do |error|

      should "be available to instiate a #{error.to_s}" do
        error.new
      end
    end
  end

  context "cache" do
    setup do
      @library = File.join(fixtures, 'sprout')
    end

    should "find library from system" do
      user = Sprout::System::OSXSystem.new
      user.stubs(:library).returns @library
      Sprout.stubs(:current_system).returns user

      expected_cache = File.join(@library, 'Sprouts', Sprout::VERSION::MAJOR_MINOR, 'cache')
      assert_equal expected_cache, Sprout.cache
    end

    should "find library for unix system" do
      user = Sprout::System::UnixSystem.new
      user.stubs(:library).returns @library
      Sprout.stubs(:current_system).returns user

      expected_cache = File.join(@library, '.sprouts', Sprout::VERSION::MAJOR_MINOR, 'cache')
      assert_equal expected_cache, Sprout.cache
    end
  end

  context "A new sprout test case" do

    should "be able to work as a particular user but then revert when done" do
      original_class = Sprout.current_system.class

      block_called = false
      as_a_unix_system do |sys|
        block_called = true
        assert_equal Sprout::System::UnixSystem, Sprout.current_system.class, "Requests for the current system should yield a UNIX system"
      end
      as_a_windows_system do |sys|
        block_called = true
        assert_equal Sprout::System::WinSystem, Sprout.current_system.class
      end
      assert_equal original_class, Sprout.current_system.class
      assert block_called, "Ensure the block was yielded to..."
    end
  end

  context "Executables" do

    context "with a sandboxed load path" do

      setup do
        path = File.join fixtures, "executable", "flex3sdk_gem"
        $:.unshift path
      end

      teardown do
        $:.shift
      end

      should "find requested executables" do
        path = Sprout::Executable.load(:mxmlc, 'flex3sdk', '>= 3.0.0').path
        assert_not_nil path
      end
    end
    
    context "with a stubbed load path" do

      setup do
        Sprout::Executable.stubs(:require_ruby_package).returns true
        @path = 'test/fixtures/process_runner/chmod_script.sh'
      end

      should "work when registered with different gem names" do
        register_executable :mxmlc, 'flex3sdk', '1.0.pre', @path
        register_executable :mxmlc, 'flex4sdk', '1.0.pre', @path
      end

      should "work when registered with different exe names" do
        register_executable :mxmlc, 'flex3sdk', '1.0.pre', @path
        register_executable :compc, 'flex3sdk', '1.0.pre', @path
      end

      context "that are registered" do
        should "work the first time" do
          register_executable :mxmlc, 'flex3sdk', '1.0.pre', @path
        end

        context "and then requested" do
          setup do
            register_executable :mxmlc, 'flex3sdk', '1.0.pre', @path
          end

          should "succeed if the executable is available and no version specified" do
            assert_equal @path, Sprout::Executable.load(:mxmlc, 'flex3sdk').path
          end

          should "succeed if version requirement is met" do
            assert_equal @path, Sprout::Executable.load(:mxmlc, 'flex3sdk', '>= 1.0.pre').path
          end

          should "fail if version requirement is not met" do
            assert_raises Sprout::Errors::LoadError do
              Sprout::Executable.load :mxmlc, 'flex3sdk', '>= 1.1.0'
            end
          end

        end
      end

      context "that are not registered" do
        should "fail when requested" do
          assert_raises Sprout::Errors::LoadError do
            Sprout::Executable.load :mxmlc, 'flex3sdk'
          end
        end
      end

    end
  end

  private

  def register_executable name, pkg_name, pkg_version, path, platform=:universal
    exe = OpenStruct.new({
      :name => name,
      :path => path,
      :pkg_name => pkg_name,
      :pkg_version => pkg_version,
      :platform => platform
    })
    Sprout::Executable.register exe
  end

end


