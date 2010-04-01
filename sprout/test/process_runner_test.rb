require File.dirname(__FILE__) + '/test_helper'

class ProcessRunnerTest < Test::Unit::TestCase
  include SproutTestCase

  def setup
    super
    @fixture = File.expand_path(File.join(fixtures, 'process_runner'))
    @mtasc = File.join(@fixture, 'mtasc-1.13-osx', 'mtasc')
    FileUtils.chmod(0644, @mtasc)

  end
  
  def teardown
    super
  end

  def test_unknown_process
    assert_raise Sprout::ProcessRunnerError do 
      runner = Sprout::ProcessRunner.new('SomeUnknownExecutableThatCantBeInYourPath --some-arg true --other-arg false')
    end
  end
  
  def test_process_mode_change
    runner = Sprout::ProcessRunner.new("#{@mtasc} --help")
    assert runner.read.match(/^Motion-Twin/)
  end

end
