require File.dirname(__FILE__) + '/test_helper'
require 'sprout/tasks/sftp_task'

class SFTPTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @file = File.join(fixtures, 'sftp', 'sprout-mockgem-9.115.5.gem')
  end
  
  def teardown
    super
  end
  
  def test_release
    sftp :release do |t|
      t.host          = 'dev.patternpark.com'
      t.local_path    = File.dirname(@file)
      t.remote_path   = '/var/www/projectsprouts/current/gems'
      t.files         = [@file]
    end

    assert(true)
    # Uncomment to run manual test...
    # You'll need a valid host, username and pass
    #run_task :release
  end
end