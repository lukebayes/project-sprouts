require 'test_helper'

class ProcessRunnerTest < Test::Unit::TestCase
  include SproutTestHelper

  context "process runner" do

    setup do
      @fixture            = File.expand_path File.join(fixtures, 'process_runner')
      @script             = File.join @fixture, 'chmod_script.sh'
      @script_with_spaces = File.join @fixture, 'dir with spaces', 'chmod_script.sh'

      pid                 = nil
      write               = StringIO.new
      read                = StringIO.new "Hello World"
      error               = StringIO.new

      @runner             = Sprout::ProcessRunner.new
      @runner.stubs(:open4_popen4_block).returns( [pid, write, read, error] )
    end

    teardown do
      FileUtils.chmod 0744, @script
      FileUtils.chmod 0744, @script_with_spaces
    end

    #--------------------------------------------------
    context "on nix" do 

      should "accept and forward multiple arguments" do
        @runner.expects(:execute_with_block).once.with("ls", "-la").returns nil
        @runner.execute_open4 "ls", "-la"
      end

      should "accept and forward no arguments" do
        @runner.expects(:execute_with_block).once.with("ls").returns nil
        @runner.execute_open4 "ls"
      end

      context "with invalid executable mode" do
        setup do
          FileUtils.chmod(0644, @script)
          FileUtils.chmod(0644, @script_with_spaces)
          # Raise the Errno::EACCESS (Bad File Mode) error
          # On the first call only - this should trigger the
          # File mode update, when encountered
          @runner.stubs(:open4_popen4_block).once.raises Errno::EACCES
        end

        context "and arguments" do
          should "update file mode" do
            execute_with_open4_and_bad_mode @script, "-n FooBar"
          end

          context "and spaces in the path" do
            should "modify invalid file modes for executables" do
              execute_with_open4_and_bad_mode @script_with_spaces, "-n FooBar"
            end
          end
        end

        context "and no arguments" do
          should "update file mode" do
            execute_with_open4_and_bad_mode @script
          end
        end
      end

    end

    #--------------------------------------------------
    context "on win32" do
      should "accept and forward multiple arguments" do
        # Comment out the following line to actually execute the process on Windows:
        @runner.expects(:execute_with_block).once.with("dir").returns nil
        @runner.execute_win32("dir")
      end

      should "attempt to load win32-open 3 gem on Ruby 1.8.6" do
        @runner.stubs(:ruby_version).returns('1.8.6')
        @runner.expects(:open3_popen3_block).never
        @runner.expects(:win32_open3_block)
        @runner.execute_win32('ls')
      end

      should "attempt to load win32-open 3 gem on Ruby 1.8.7" do
        @runner.stubs(:ruby_version).returns('1.8.7')
        @runner.expects(:open3_popen3_block).never
        @runner.expects(:win32_open3_block)
        @runner.execute_win32('ls')
      end

      should "NOT load win32-open 3 gem on Ruby 1.9.2" do
        @runner.stubs(:ruby_version).returns('1.9.2')
        @runner.expects(:win32_open3_block).never
        @runner.expects(:open3_popen3_block)
        @runner.execute_win32('ls')
      end

    end



    context "an unknown process" do
      should "raise an exception if the executable doesn't exist" do
        assert_raise Sprout::Errors::ProcessRunnerError do 
          @runner.stubs(:open4_popen4_block).raises Errno::ENOENT
          @runner.execute_open4('SomeUnknownExecutableThatCantBeInYourPath', '--some-arg true --other-arg false')
        end
      end
    end

  end

  private
  
  def execute_with_open4_and_bad_mode(command, options="")
    assert !File.stat(command).executable?, "File should not be executable to begin"
    @runner.expects(:update_executable_mode)
    @runner.execute_open4 command, options
    assert_matches /^Hello World/, @runner.read
  end

end

