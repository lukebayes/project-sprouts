require "rubygems"
require "bundler"
Bundler.setup(:default, :test)
require 'shoulda'

require File.dirname(__FILE__) + '/../../lib/sprout'
require File.dirname(__FILE__) + '/../sprout_test_case'

# Prevent log messages from interrupting the test output:
Sprout::Log.debug = true


