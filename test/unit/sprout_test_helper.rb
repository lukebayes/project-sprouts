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
require 'sprout/test/sprout_test_case'

class Test::Unit::TestCase

  # Only clear registrations in the Sprout core
  # project - not in child projects
  def teardown
    super
    Sprout::Executable.clear_entities!
    Sprout::Library.clear_entities!
    Sprout::Generator.clear_entities!
  end
end

