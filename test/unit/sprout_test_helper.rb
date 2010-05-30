require "rubygems"
require "bundler"

Bundler.setup :default, :development

# These require statments *must* be in this order:
# http://bit.ly/bCC0Ew
# Somewhat surprised they're not being required by Bundler...
require 'shoulda'
require 'mocha'

require File.dirname(__FILE__) + '/../../lib/sprout'
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'unit/fake_process_runner'
require 'unit/fake_executable_task'
require 'unit/sprout_test_case'

# Prevent log messages from interrupting the test output:
Sprout::Log.debug = true
Sprout::ProgressBar.debug = true

