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

      expected_cache = File.join(@library, 'Sprouts', 'cache', Sprout::VERSION::MAJOR_MINOR)
      assert_equal expected_cache, Sprout.cache
    end

    should "find library for unix system" do
      user = Sprout::System::UnixSystem.new
      user.stubs(:library).returns @library
      Sprout.stubs(:current_system).returns user

      expected_cache = File.join(@library, '.sprouts', 'cache', Sprout::VERSION::MAJOR_MINOR)
      assert_equal expected_cache, Sprout.cache
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
        #as_a_mac_user do
          path = Sprout.load_executable :mxmlc, 'flex3sdk', '>= 3.0.0'
          assert_not_nil path
        #end
      end
    end
    
    context "with a stubbed load path" do

      setup do
        Sprout.stubs(:require_rb_for_executable).returns true
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
            assert_equal @path, Sprout.load_executable(:mxmlc, 'flex3sdk')
          end

          should "succeed if version requirement is met" do
            assert_equal @path, Sprout.load_executable(:mxmlc, 'flex3sdk', '>= 1.0.pre')
          end

          should "fail if version requirement is not met" do
            assert_raises Sprout::Errors::MissingExecutableError do
              exe = Sprout.load_executable :mxmlc, 'flex3sdk', '>= 1.1.0'
            end
          end

        end
      end

      context "that are not registered" do
        should "fail when requested" do
          assert_raises Sprout::Errors::MissingExecutableError do
            exe = Sprout.load_executable :mxmlc, 'flex3sdk'
          end
        end
      end

    end
  end

  private

  def register_executable name, pkg_name, pkg_version, path, platform=:macosx
    exe = Sprout::ExecutableTarget.new({
      :name => name,
      :path => path,
      :pkg_name => pkg_name,
      :pkg_version => pkg_version,
      :platform => platform
    })
    Sprout.register_executable exe
  end

end


