require 'test/unit'
require 'rubygems'
require 'rake'

# If this is running within the directory structure found in
# svn, there is no need for an ENV, if this project is running
# indiidually, SPROUT_HOME should be a system or vm var and set 
# Your local path where you've checked out the following branch:
# https://projectsprouts.googlecode.com/svn/branches/rubygems/sprouts/sprout
SPROUT_HOME = ENV['SPROUT_HOME']
$:.push(SPROUT_HOME + '/sprout/lib')
$:.push(SPROUT_HOME + '/sprout/test')

$:.push(File.dirname(__FILE__) + '/../lib')
$:.push(File.dirname(__FILE__))

require 'sprout'
require 'sprout/flashplayer'
require 'generator_test_helper'

Sprout::Log.debug = true

module SproutTestCase

  def setup
    @local_generators = File.expand_path(File.join(File.dirname(__FILE__), '/../lib/sprout'))
    super
  end
  
  def local_generators
  end

  def fixtures
    @fixtures ||= File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
  end
end
