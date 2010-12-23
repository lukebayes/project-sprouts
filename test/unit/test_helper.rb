require "rubygems"
require "bundler"

Bundler.setup :default, :development

# These require statments *must* be in this order:
# http://bit.ly/bCC0Ew
# Somewhat surprised they're not being required by Bundler...
require 'shoulda'
require 'mocha'

lib = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift lib unless $:.include? lib

require 'sprout'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'unit/fake_process_runner'
require 'unit/fake_executable_task'
require 'sprout/test_helper'

class Test::Unit::TestCase

  # Only clear registrations in the Sprout core
  # project - not in child projects
  def teardown
    Sprout::Executable.clear_entities!
    Sprout::Library.clear_entities!
    Sprout::Generator.clear_entities!
  end
end

