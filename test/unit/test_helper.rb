require "rubygems"
require "bundler"
Bundler.setup(:default, :test)

require 'mocha'
require 'shoulda'

require File.dirname(__FILE__) + '/../../lib/sprout'

$:.push File.dirname(__FILE__)
require 'fake_io'
require 'fake_process_runner'
require 'sprout_test_case'

# Prevent log messages from interrupting the test output:
Sprout::Log.debug = true


