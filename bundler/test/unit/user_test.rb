require File.dirname(__FILE__) + '/test_helper'

class UserTest <  Test::Unit::TestCase
  include SproutTestCase

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
    
    # TODO: We have a problem with ProcessRunner in the Flex 3 SDK run from a DOS Shell
    # when the compiled input is a .CSS document and there are compilation errors.
    # The ProcessRunner is blocked trying to read stdout, but the compiler has only written
    # to stderr.
    should "execute without error" do
      runner = ProcessRunnerStub.new('some command')
      runner.error = "[MOCK ERROR]"

      user = UserStub.new(runner)
      assert user
      
  #    user.execute('')
    end

    should "fix crlf (Windows) line endings in an executable for nix users" do
      user = Sprout::UnixUser.new
      output = user.execute @mxmlc
      assert_not_nil output, "Output should not be nil"
      assert output.match(/success/)
    end
  end
end

class UserStub < Sprout::UnixUser #:nodoc:
  attr_accessor :error
  
  def initialize(runner)
    @runner = runner
    super()
  end
  
  def get_process_runner(command)
    @runner.command = command
    @runner
  end
end

class ProcessRunnerStub #:nodoc:
  attr_accessor :command
  attr_accessor :error
  attr_accessor :result
  
  def initialize(command)
    @command = command
    @error = ''
  end
  
  def read
    return @result unless @result.nil?
    sleep(5.0)
    return ""
  end
  
  def read_err
    return @error
  end
end
