require File.dirname(__FILE__) + '/test_helper'

class ProcessRunnerTest < Test::Unit::TestCase
  include SproutTestCase

  context "process runner" do

    setup do
      @fixture = File.expand_path(File.join(fixtures, 'process_runner'))
      @mtasc = File.join(@fixture, 'mtasc-1.13-osx', 'mtasc')
      FileUtils.chmod(0644, @mtasc)
    end

    teardown do
      FileUtils.chmod(0755, @mtasc)
    end
  
    should "modify invalid file modes for executables" do
      runner = Sprout::ProcessRunner.new("#{@mtasc} --help")
      assert runner.read.match(/^Motion-Twin/)
    end

    context "an unknown process" do
      should "raise an exception if the executable doesn't exist" do
        assert_raise Sprout::ProcessRunnerError do 
          runner = Sprout::ProcessRunner.new('SomeUnknownExecutableThatCantBeInYourPath --some-arg true --other-arg false')
        end
      end
    end

  end
end

